using GadgeonFinanceTracker.Data;
using GadgeonFinanceTracker.Models.Domain;
using GadgeonFinanceTracker.Models.DTO;
using GadgeonFinanceTracker.Repository;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;

namespace GadgeonFinanceTracker.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> userManager;
        private readonly ITokenRepo tokenRepo;
        private readonly FinanceTrackerAuthDbContext authDbContext;

        public AuthController(UserManager<ApplicationUser> userManager, ITokenRepo tokenRepo,FinanceTrackerAuthDbContext authDbContext)
        {
            this.userManager = userManager;
            this.tokenRepo = tokenRepo;
            this.authDbContext = authDbContext;

        }

        //POST: /api/Auth/Register
        [HttpPost]
        [Route("Register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequestDTO registerRequestDTO)
        {
            var identityUser = new ApplicationUser
            {
                UserName = registerRequestDTO.Username,
                Email = registerRequestDTO.Username
            };

            var identityResult = await userManager.CreateAsync(identityUser, registerRequestDTO.Password);

            if (identityResult.Succeeded)
            {
                if (registerRequestDTO.Roles != null && registerRequestDTO.Roles.Any())
                {
                    identityResult = await userManager.AddToRolesAsync(identityUser, registerRequestDTO.Roles);

                    if (identityResult.Succeeded)
                        return Ok("User Registered Successfully");
                    else
                        return BadRequest(identityResult.Errors);
                }

                return Ok("User Registered Successfully. No roles assigned.");
            }

            return BadRequest(identityResult.Errors);
        }

        [HttpPost]
        [Route("Login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDTO loginRequestDTO)
        {
            var user = await userManager.FindByNameAsync(loginRequestDTO.Username);
            if (user != null && await userManager.CheckPasswordAsync(user, loginRequestDTO.Password))
            {
                var roles = await userManager.GetRolesAsync(user);

                if (roles != null && roles.Any())
                {
                    var jwtToken = tokenRepo.CreateJWTToken(user, roles.ToList());
                    var refreshToken = tokenRepo.CreateRefreshToken();

                    var refreshTokenEntity = new RefreshToken
                    {
                        Token = refreshToken,
                        UserId = user.Id,
                        ExpiresAt = DateTime.UtcNow.AddDays(30),
                        IsRevoked = false
                    };

                    await authDbContext.RefreshTokens.AddAsync(refreshTokenEntity);
                    await authDbContext.SaveChangesAsync();

                    return Ok(new LoginResponseDTO
                    {
                        JwtToken = jwtToken,
                        RefreshToken = refreshToken
                    });
                }

                return Ok("Login successful");
            }
            return Unauthorized("Invalid username or password");
        }

        [HttpPut]
        [Route("UpdateProfile")]
        [Authorize]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDTO updateProfileDTO)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await userManager.FindByIdAsync(userId);

            if (user == null) return NotFound("User not found");

            // update email
            if (!string.IsNullOrEmpty(updateProfileDTO.Email))
            {
                user.Email = updateProfileDTO.Email;
                user.UserName = updateProfileDTO.Email;
            }

            // update name
            if (!string.IsNullOrEmpty(updateProfileDTO.Name))
            {
                user.Name = updateProfileDTO.Name;
            }

            // update password
            if (!string.IsNullOrEmpty(updateProfileDTO.CurrentPassword) &&
                !string.IsNullOrEmpty(updateProfileDTO.NewPassword))
            {
                var passwordResult = await userManager.ChangePasswordAsync(
                    user, updateProfileDTO.CurrentPassword, updateProfileDTO.NewPassword);

                if (!passwordResult.Succeeded)
                    return BadRequest(passwordResult.Errors);
            }

            var result = await userManager.UpdateAsync(user);

            if (result.Succeeded)
                return Ok("Profile updated successfully");

            return BadRequest(result.Errors);
        }

        [HttpGet]
        [Route("Profile")]
        [Authorize]
        public async Task<IActionResult> GetProfile()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await userManager.FindByIdAsync(userId);

            if (user == null) return NotFound("User not found");

            return Ok(new
            {
                Name = user.Name,
                Email = user.Email
            });
        }

        [HttpPost]
        [Route("Refresh")]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequestDTO refreshRequestDTO)
        {
            var refreshToken = await authDbContext.RefreshTokens
                .FirstOrDefaultAsync(r => r.Token == refreshRequestDTO.RefreshToken);

            if (refreshToken == null || !refreshToken.IsActive)
                return Unauthorized("Invalid or expired refresh token");

            var user = await userManager.FindByIdAsync(refreshToken.UserId);
            if (user == null)
                return Unauthorized("User not found");

            // revoke old token
            refreshToken.IsRevoked = true;

            // create new tokens
            var roles = await userManager.GetRolesAsync(user);
            var newJwtToken = tokenRepo.CreateJWTToken(user, roles.ToList());
            var newRefreshToken = tokenRepo.CreateRefreshToken();

            var newRefreshTokenEntity = new RefreshToken
            {
                Token = newRefreshToken,
                UserId = user.Id,
                ExpiresAt = DateTime.UtcNow.AddDays(30),
                IsRevoked = false
            };

            await authDbContext.RefreshTokens.AddAsync(newRefreshTokenEntity);
            await authDbContext.SaveChangesAsync();

            return Ok(new LoginResponseDTO
            {
                JwtToken = newJwtToken,
                RefreshToken = newRefreshToken
            });
        }

        [HttpPost]
        [Route("GoogleToken")]
        public async Task<IActionResult> GoogleToken([FromBody] GoogleTokenRequestDTO dto)
        {
            try
            {
                // verify Google ID token
                var payload = await Google.Apis.Auth.GoogleJsonWebSignature.ValidateAsync(dto.IdToken);

                var email = payload.Email;
                var name = payload.Name;

                // find or create user
                var user = await userManager.FindByEmailAsync(email);
                if (user == null)
                {
                    user = new ApplicationUser
                    {
                        UserName = email,
                        Email = email,
                        Name = name,
                        EmailConfirmed = true
                    };
                    await userManager.CreateAsync(user);
                    await userManager.AddToRolesAsync(user, new[] { "Reader" });
                }

                // generate tokens
                var roles = await userManager.GetRolesAsync(user);
                var jwtToken = tokenRepo.CreateJWTToken(user, roles.ToList());
                var refreshToken = tokenRepo.CreateRefreshToken();

                var refreshTokenEntity = new RefreshToken
                {
                    Token = refreshToken,
                    UserId = user.Id,
                    ExpiresAt = DateTime.UtcNow.AddDays(30),
                    IsRevoked = false
                };
                await authDbContext.RefreshTokens.AddAsync(refreshTokenEntity);
                await authDbContext.SaveChangesAsync();

                return Ok(new LoginResponseDTO
                {
                    JwtToken = jwtToken,
                    RefreshToken = refreshToken
                });
            }
            catch (Exception ex)
            {
                return Unauthorized($"Invalid Google token: {ex.Message}");
            }
        }
    }
}
