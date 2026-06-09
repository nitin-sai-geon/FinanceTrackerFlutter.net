using System.ComponentModel.DataAnnotations;

namespace GadgeonFinanceTracker.Models.DTO
{
    public class UpdateTransactionDTO
    {
        [Required]
        public decimal Amount { get; set; }

        [Required]
        public string Description { get; set; }

        [Required]
        public DateOnly Date { get; set; }

        [Required]
        public Guid CategoryId { get; set; }
    }
}