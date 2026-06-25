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
        private readonly ILogger<AuthController> logger;

        public AuthController(UserManager<ApplicationUser> userManager, ITokenRepo tokenRepo,
            FinanceTrackerAuthDbContext authDbContext, ILogger<AuthController> logger)
        {
            this.userManager = userManager;
            this.tokenRepo = tokenRepo;
            this.authDbContext = authDbContext;
            this.logger = logger;
        }

        [HttpPost]
        [Route("Register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequestDTO registerRequestDTO)
        {
            logger.LogInformation("Registration attempt for {Username}", registerRequestDTO.Username);
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
                    {
                        logger.LogInformation("User {Username} registered with roles {Roles}", registerRequestDTO.Username, string.Join(", ", registerRequestDTO.Roles));
                        return Ok("User Registered Successfully");
                    }
                    else
                    {
                        logger.LogWarning("Role assignment failed for {Username}", registerRequestDTO.Username);
                        return BadRequest(identityResult.Errors);
                    }
                }

                logger.LogInformation("User {Username} registered with no roles", registerRequestDTO.Username);
                return Ok("User Registered Successfully. No roles assigned.");
            }

            logger.LogWarning("Registration failed for {Username}", registerRequestDTO.Username);
            return BadRequest(identityResult.Errors);
        }

        [HttpPost]
        [Route("Login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDTO loginRequestDTO)
        {
            logger.LogInformation("Login attempt for {Username}", loginRequestDTO.Username);
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

                    logger.LogInformation("User {Username} logged in successfully", loginRequestDTO.Username);
                    return Ok(new LoginResponseDTO
                    {
                        JwtToken = jwtToken,
                        RefreshToken = refreshToken
                    });
                }

                return Ok("Login successful");
            }

            logger.LogWarning("Failed login attempt for {Username}", loginRequestDTO.Username);
            return Unauthorized("Invalid username or password");
        }

        [HttpPut]
        [Route("UpdateProfile")]
        [Authorize]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDTO updateProfileDTO)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            logger.LogInformation("Profile update request for user {UserId}", userId);
            var user = await userManager.FindByIdAsync(userId);

            if (user == null)
            {
                logger.LogWarning("Profile update failed: user {UserId} not found", userId);
                return NotFound("User not found");
            }

            if (!string.IsNullOrEmpty(updateProfileDTO.Email))
            {
                user.Email = updateProfileDTO.Email;
                user.UserName = updateProfileDTO.Email;
            }

            if (!string.IsNullOrEmpty(updateProfileDTO.Name))
                user.Name = updateProfileDTO.Name;

            if (!string.IsNullOrEmpty(updateProfileDTO.CurrentPassword) &&
                !string.IsNullOrEmpty(updateProfileDTO.NewPassword))
            {
                var passwordResult = await userManager.ChangePasswordAsync(
                    user, updateProfileDTO.CurrentPassword, updateProfileDTO.NewPassword);

                if (!passwordResult.Succeeded)
                {
                    logger.LogWarning("Password change failed for user {UserId}", userId);
                    return BadRequest(passwordResult.Errors);
                }
            }

            var result = await userManager.UpdateAsync(user);

            if (result.Succeeded)
            {
                logger.LogInformation("Profile updated for user {UserId}", userId);
                return Ok("Profile updated successfully");
            }

            logger.LogWarning("Profile update failed for user {UserId}", userId);
            return BadRequest(result.Errors);
        }

        [HttpGet]
        [Route("Profile")]
        [Authorize]
        public async Task<IActionResult> GetProfile()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await userManager.FindByIdAsync(userId);

            if (user == null)
            {
                logger.LogWarning("Profile fetch failed: user {UserId} not found", userId);
                return NotFound("User not found");
            }

            return Ok(new { Name = user.Name, Email = user.Email });
        }

        [HttpPost]
        [Route("Refresh")]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequestDTO refreshRequestDTO)
        {
            var refreshToken = await authDbContext.RefreshTokens
                .FirstOrDefaultAsync(r => r.Token == refreshRequestDTO.RefreshToken);

            if (refreshToken == null || !refreshToken.IsActive)
            {
                logger.LogWarning("Token refresh rejected: invalid or expired token");
                return Unauthorized("Invalid or expired refresh token");
            }

            var user = await userManager.FindByIdAsync(refreshToken.UserId);
            if (user == null)
            {
                logger.LogWarning("Token refresh rejected: user {UserId} not found", refreshToken.UserId);
                return Unauthorized("User not found");
            }

            refreshToken.IsRevoked = true;

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

            logger.LogInformation("Tokens refreshed for user {UserId}", user.Id);
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
                var payload = await Google.Apis.Auth.GoogleJsonWebSignature.ValidateAsync(dto.IdToken);
                var email = payload.Email;
                var name = payload.Name;

                var user = await userManager.FindByEmailAsync(email);
                if (user == null)
                {
                    logger.LogInformation("Creating new user for Google account {Email}", email);
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

                logger.LogInformation("Google sign-in successful for {Email}", email);
                return Ok(new LoginResponseDTO
                {
                    JwtToken = jwtToken,
                    RefreshToken = refreshToken
                });
            }
            catch (Exception ex)
            {
                logger.LogWarning(ex, "Google token validation failed");
                return Unauthorized($"Invalid Google token: {ex.Message}");
            }
        }
    }
}
