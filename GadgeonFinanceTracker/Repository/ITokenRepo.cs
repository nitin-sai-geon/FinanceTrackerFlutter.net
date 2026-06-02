using Microsoft.AspNetCore.Identity;

namespace GadgeonFinanceTracker.Repository
{
    public interface ITokenRepo
    {
        public string CreateJWTToken(IdentityUser user, List<string> roles);
     

    }
}
