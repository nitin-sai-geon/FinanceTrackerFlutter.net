using System.ComponentModel.DataAnnotations;

namespace GadgeonFinanceTracker.Models.DTO
{
    public class UpdateProfileDTO
    {
        public string? Name { get; set; }

        [EmailAddress(ErrorMessage = "Invalid email address format")]
        public string? Email { get; set; }

        public string? CurrentPassword { get; set; }

        [MinLength(6)]
        public string? NewPassword { get; set; }
    }
}