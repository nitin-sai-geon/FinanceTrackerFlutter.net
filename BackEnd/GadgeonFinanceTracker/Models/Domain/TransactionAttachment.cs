namespace GadgeonFinanceTracker.Models.Domain
{
    public class TransactionAttachment
    {
        public Guid Id { get; set; }
        public Guid TransactionId { get; set; }         // FK to Transactions
        public Transaction Transaction { get; set; }    // navigation property
        public string FileName { get; set; }            // original file name
        public string FilePath { get; set; }            // server path or blob URL
        public string ContentType { get; set; }         // "image/png" or "image/svg+xml"
        public long FileSizeBytes { get; set; }         // file size
        public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
    }
}
