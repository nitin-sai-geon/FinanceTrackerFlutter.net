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
           .ForMember(dest => dest.AttachmentPath,
               opt => opt.MapFrom(src => src.Attachment != null ? src.Attachment.FilePath : null));

            CreateMap<AddTransactionDTO, Transaction>();
            CreateMap<UpdateTransactionDTO, Transaction>();

            CreateMap<Category, CategoryResponseDTO>();


        }
    }
}