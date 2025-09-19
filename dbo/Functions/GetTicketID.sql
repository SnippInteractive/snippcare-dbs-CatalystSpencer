CREATE FUNCTION [dbo].[GetTicketID] 
(
	-- Add the parameters for the function here
	
)
--Select dbo.GetTicketNo()
RETURNS VARCHAR(15)
AS
BEGIN
		Declare @TicketNo Varchar(15)

		Select @TicketNo=Convert(Varchar,(Select IsNull(Max(TicketId)+1,1) from Ticket))+convert(varchar, getdate(), 112) 
        
		RETURN @TicketNo    
End
