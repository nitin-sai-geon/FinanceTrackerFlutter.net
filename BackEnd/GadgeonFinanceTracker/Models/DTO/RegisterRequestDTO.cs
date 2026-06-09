using System.ComponentModel.DataAnnotations;

namespace GadgeonFinanceTracker.Models.DTO
{
    public class RegisterRequestDTO
    {
        [Required]
        public string? Name { get; set; }

        [Required]
        [EmailAddress(ErrorMessage = "Invalid email address format")]
        public string Username { get; set; }

        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        public string[] Roles { get; set; }
    }
}