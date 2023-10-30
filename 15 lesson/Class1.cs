using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SqlServer.Server;
using System.Collections;
using System.Data.SqlClient;


namespace CLR_test
{
    public class CLR_Procedure
    {
        
        [SqlFunction(DataAccess = DataAccessKind.Read)]
        public static decimal SumSalesCustomer(int customerID)
        {
            using (SqlConnection connection = new SqlConnection("context connection=true"))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT SUM(SIL.ExtendedPrice)  FROM [Sales].[Invoices] SI JOIN [Sales].[InvoiceLines] SIL on SI.InvoiceID=SIL.InvoiceID WHERE SI.CustomerID=@CustomerID;", connection))
            {
                cmd.Parameters.AddWithValue("customerID", customerID);
                connection.Open();
                var sumSales = (decimal)cmd.ExecuteScalar();
                return sumSales;
            }
        }






    }
}


