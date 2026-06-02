using System.ComponentModel.DataAnnotations;

namespace GadgeonFinanceTracker.Models.DTO
{
    public class TransactionRequestDTO
    {
         
        public Guid Id { get; set; }

         
        public string UserId { get; set; }

         
        public decimal Amount { get; set; }

         
        public string Description { get; set; }

         
        public DateOnly Date { get; set; }

         
        public Guid CategoryId { get; set; }

        public string CategoryName { get; set; }
    }
}