using GadgeonFinanceTracker.Models.DTO;
using GadgeonFinanceTracker.Models.DTO;
using GadgeonFinanceTracker.Repository;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using GadgeonFinanceTracker.Models.Domain;

namespace GadgeonFinanceTracker.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> userManager;
        private readonly ITokenRepo tokenRepo;
        public AuthController(UserManager<ApplicationUser> userManager, ITokenRepo tokenRepo)
        {
            this.userManager = userManager;
            this.tokenRepo = tokenRepo;
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
                //token logic:
                var roles = await userManager.GetRolesAsync(user);

                if (roles != null && roles.Any())
                {
                    var jwttoken = tokenRepo.CreateJWTToken(user, roles.ToList());
                    var response = new LoginResponseDTO
                    {
                        JwtToken = jwttoken
                    };
                    return Ok(response); //for future additions to login response dto like user details, roles etc we can use this response dto instead of just returning the token

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
    }
}
