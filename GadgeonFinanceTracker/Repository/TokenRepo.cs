using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
namespace GadgeonFinanceTracker.Repository
{
    public class TokenRepo:ITokenRepo
    {
        public IConfiguration configuration;
        public TokenRepo(IConfiguration configuration)
        {
            this.configuration = configuration;
        }
        //Create claims for the user and their roles, then create a JWT token using these claims and return it as a string.
        public string CreateJWTToken(IdentityUser user, List<string> roles)
       { 
        
            var claims = new List<Claim>();
            claims.Add(new Claim(ClaimTypes.NameIdentifier, user.Id));
            claims.Add(new Claim(ClaimTypes.Email, user.Email));
            //claims.Add(new Claim(ClaimTypes.Email, user.Email));

            foreach(var role in roles)
            {   
                claims.Add(new Claim(ClaimTypes.Role, role));
            }


            var key= new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]));

            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: configuration["Jwt:Issuer"],
                audience: configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddHours(1),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token); 
        }

        public string CreateRefreshToken()
        {
            var randomBytes = new byte[64];
            using var rng = System.Security.Cryptography.RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);
            return Convert.ToBase64String(randomBytes);
        }

    }
}
