using GadgeonFinanceTracker.Models.Domain;
using GadgeonFinanceTracker.Models.DTO;
using GadgeonFinanceTracker.Repository;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
namespace GadgeonFinanceTracker.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GoogleAuthController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> userManager;
        private readonly ITokenRepo tokenRepo;
        private readonly ILogger<GoogleAuthController> logger;

        public GoogleAuthController(UserManager<ApplicationUser> userManager, ITokenRepo tokenRepo,
            ILogger<GoogleAuthController> logger)
        {
            this.userManager = userManager;
            this.tokenRepo = tokenRepo;
            this.logger = logger;
        }

        [HttpGet("login")]
        public IActionResult Login([FromQuery] string? sessionId)
        {
            logger.LogInformation("Google OAuth flow initiated (sessionId: {SessionId})", sessionId);
            var properties = new AuthenticationProperties
            {
                RedirectUri = Url.Action("Callback", "GoogleAuth"),
                Items = { { "sessionId", sessionId } }
            };
            return Challenge(properties, GoogleDefaults.AuthenticationScheme);
        }

        [HttpGet("callback")]
        public async Task<IActionResult> Callback(
        [FromServices] Dictionary<string, string?> sessionStore)
        {
            var result = await HttpContext.AuthenticateAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            if (!result.Succeeded)
            {
                logger.LogWarning("Google OAuth callback authentication failed");
                return Unauthorized();
            }

            var email = result.Principal.FindFirst(ClaimTypes.Email)?.Value;
            var name = result.Principal.FindFirst(ClaimTypes.Name)?.Value;
            var sessionId = result.Properties.Items.TryGetValue("sessionId", out var sid) ? sid : null;

            if (string.IsNullOrEmpty(email))
            {
                logger.LogWarning("Google OAuth callback: no email in principal");
                return Unauthorized();
            }

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
            var token = tokenRepo.CreateJWTToken(user, roles.ToList());

            if (sessionId != null)
                sessionStore[sessionId] = token;

            logger.LogInformation("Google OAuth callback completed for {Email} (sessionId: {SessionId})", email, sessionId);
            return Content("<html><body><h2>Sign in successful. Return to the app.</h2></body></html>", "text/html");
        }

        [HttpGet("session/{sessionId}")]
        public IActionResult GetSession(string sessionId,
        [FromServices] Dictionary<string, string?> sessionStore)
        {
            if (sessionStore.TryGetValue(sessionId, out var token) && token != null)
            {
                sessionStore.Remove(sessionId);
                logger.LogInformation("Session {SessionId} claimed and removed", sessionId);
                return Ok(new { status = "completed", jwtToken = token });
            }

            return Ok(new { status = "pending" });
        }
    }
}