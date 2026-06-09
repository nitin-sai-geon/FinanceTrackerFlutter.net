namespace GadgeonFinanceTracker.Models.DTO
{
	public class GoogleLoginResponseDTO
	{
		public string JwtToken { get; set; }
		public string Email { get; set; }
		public string? Name { get; set; }
	}
}