using Microsoft.AspNetCore.Identity;

namespace GadgeonFinanceTracker.Models.Domain
{
    public class ApplicationUser : IdentityUser
    {
        public string? Name { get; set; }
    }
}