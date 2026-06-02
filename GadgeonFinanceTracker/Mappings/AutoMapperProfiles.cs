using AutoMapper;
using GadgeonFinanceTracker.Models.Domain;
using GadgeonFinanceTracker.Models.DTO;

namespace GadgeonFinanceTracker.Mappings
{
    public class AutoMapperProfiles : Profile
    {
        public AutoMapperProfiles()
        {
            CreateMap<Transaction, TransactionRequestDTO>()
                .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.Name));

            CreateMap<AddTransactionDTO, Transaction>();
            CreateMap<UpdateTransactionDTO, Transaction>();

            CreateMap<Category, CategoryResponseDTO>();
        }
    }
}