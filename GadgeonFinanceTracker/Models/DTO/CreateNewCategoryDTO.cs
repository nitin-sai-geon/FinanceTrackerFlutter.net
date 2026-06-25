using GadgeonFinanceTracker.Models.Domain;

namespace GadgeonFinanceTracker.Models.DTO
{
    public class CreateNewCategoryDTO
    {
        public string Name { get; set; }
        public CategoryType Type { get; set; } // 0 = Income, 1 = Expense
    } 
}
