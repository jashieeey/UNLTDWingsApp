<%@ Page Title="Today's Orders" Language="C#" AutoEventWireup="true" CodeBehind="TodaysOrders.aspx.cs" Inherits="UNLTDWingsApp.TodaysOrders" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Today's Orders - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background-color: #F5F0EB; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        .container-main { padding: 20px; max-width: 1400px; margin: 0 auto; }
        
        .page-header {
            background: linear-gradient(135deg, #5E2D10 0%, #8B4513 100%);
            padding: 20px;
     color: white;
       border-radius: 10px;
 margin-bottom: 20px;
      display: flex;
        justify-content: space-between;
            align-items: center;
        }

        .page-title { font-size: 24px; font-weight: 700; margin: 0; }
        
        .filter-tabs {
 display: flex;
     gap: 10px;
   margin-bottom: 20px;
            flex-wrap: wrap;
        }

     .filter-tab {
        padding: 10px 20px;
   border: 2px solid #ddd;
   background: white;
          border-radius: 20px;
      cursor: pointer;
      transition: all 0.3s ease;
            font-weight: 600;
   color: #666;
  text-decoration: none;
        }

        .filter-tab:hover {
            border-color: #5E2D10;
 color: #5E2D10;
            text-decoration: none;
   }

        .filter-tab.active {
            background: #5E2D10;
  color: white;
            border-color: #5E2D10;
     }

        .search-container {
 margin-bottom: 20px;
       display: flex;
       gap: 10px;
  }

        .search-box {
      flex: 1;
            padding: 12px;
      border: 1px solid #ddd;
         border-radius: 8px;
            font-size: 14px;
        }

        .order-table {
  width: 100%;
            background: white;
   border-collapse: collapse;
    border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .order-table thead {
            background: #5E2D10;
     color: white;
        }

        .order-table th {
   padding: 15px;
       text-align: left;
            font-weight: 700;
        }

        .order-table td {
 padding: 12px 15px;
          border-bottom: 1px solid #f0e8e0;
        }

        .order-table tr:hover {
   background: #faf8f5;
        }

        .order-id {
            font-weight: 700;
   color: #5E2D10;
        }

        .order-type-badge {
    display: inline-block;
         padding: 6px 12px;
    border-radius: 15px;
   font-size: 12px;
        font-weight: 600;
        }

        .badge-dine-in { background: #E7F3FF; color: #007bff; }
        .badge-delivery { background: #E8F5E9; color: #28a745; }
        .badge-takeout { background: #FFF8E1; color: #ffc107; }

        .status-dropdown {
  padding: 8px 12px;
    border: 1px solid #ddd;
      border-radius: 6px;
            cursor: pointer;
        }

        .action-buttons {
            display: flex;
      gap: 8px;
        }

        .btn-sm {
  padding: 8px 12px;
border: none;
            border-radius: 6px;
    cursor: pointer;
            font-weight: 600;
transition: all 0.3s ease;
        }

        .btn-delete {
background: #dc3545;
   color: white;
        }

        .btn-delete:hover {
         background: #c82333;
        }

        .empty-state {
  text-align: center;
 padding: 60px 20px;
 color: #888;
            background: white;
            border-radius: 10px;
        }

        .empty-state i {
    font-size: 4rem;
            color: #ddd;
    margin-bottom: 15px;
        }

        .summary-cards {
display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
     margin-bottom: 20px;
        }

        .summary-card {
            background: white;
padding: 20px;
            border-radius: 10px;
    text-align: center;
          box-shadow: 0 2px 8px rgba(0,0,0,0.05);
      }

    .summary-card-value {
          font-size: 28px;
    font-weight: 700;
            color: #5E2D10;
        }

        .summary-card-label {
            font-size: 12px;
            color: #888;
            margin-top: 8px;
}

    .btn { padding: 10px 20px; border: none; border-radius: 6px; cursor: pointer; font-weight: 600; transition: all 0.3s ease; }
        .btn-primary { background: #5E2D10; color: white; }
     .btn-primary:hover { background: #4a230c; }
  .btn-secondary { background: #ddd; color: #333; }
        .btn-secondary:hover { background: #ccc; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-main">
            <!-- Header -->
       <div class="page-header">
     <div class="d-flex align-items-center gap-3">
    <a href="Dashboard.aspx" style="color:white; font-size:1.3rem; text-decoration:none;"><i class="bi bi-arrow-left"></i></a>
    <div>
    <h1 class="page-title">
      <i class="bi bi-receipt-cutoff me-2"></i>Today's Orders
     </h1>
  <small style="opacity: 0.8;">Showing all orders from today &mdash; resets daily</small>
 </div>
     </div>
         <div style="text-align: right;">
        <asp:Label ID="lblOrderCount" runat="server" style="font-size: 28px; font-weight: 700;"></asp:Label>
<div style="font-size: 12px; opacity: 0.8;">Total Orders</div>
   </div>
       </div>

            <!-- Summary Cards -->
            <div class="summary-cards">
             <div class="summary-card">
        <div class="summary-card-value"><asp:Label ID="lblActiveCount" runat="server">0</asp:Label></div>
           <div class="summary-card-label">Active Orders</div>
             </div>
       <div class="summary-card">
     <div class="summary-card-value"><asp:Label ID="lblCompletedCount" runat="server">0</asp:Label></div>
        <div class="summary-card-label">Completed</div>
       </div>
   <div class="summary-card">
       <div class="summary-card-value">PHP <asp:Label ID="lblTotalRevenue" runat="server">0</asp:Label></div>
         <div class="summary-card-label">Total Revenue</div>
          </div>
       <div class="summary-card">
       <div class="summary-card-value"><asp:Label ID="lblLowStockCount" runat="server">0</asp:Label></div>
       <div class="summary-card-label"><i class="bi bi-exclamation-triangle" style="color:#ffc107;"></i> Low Stock Items</div>
          </div>
  </div>

       <!-- Filter Tabs -->
            <div class="filter-tabs">
         <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="filter-tab active" OnClick="FilterTab_Click" CommandArgument="">
           All Orders
       </asp:LinkButton>
    <asp:LinkButton ID="btnFilterDineIn" runat="server" CssClass="filter-tab" OnClick="FilterTab_Click" CommandArgument="Dine-in">
          <i class="bi bi-table me-1"></i>Dine-in
    </asp:LinkButton>
        <asp:LinkButton ID="btnFilterDelivery" runat="server" CssClass="filter-tab" OnClick="FilterTab_Click" CommandArgument="Delivery">
        <i class="bi bi-truck me-1"></i>Delivery
</asp:LinkButton>
  <asp:LinkButton ID="btnFilterTakeout" runat="server" CssClass="filter-tab" OnClick="FilterTab_Click" CommandArgument="Takeout">
 <i class="bi bi-bag me-1"></i>Takeout
             </asp:LinkButton>
            </div>

 <!-- Search -->
            <div class="search-container">
      <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box" PlaceHolder="Search by Order ID or Customer Name..."></asp:TextBox>
      <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
        <asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="btn btn-secondary" OnClick="btnClearSearch_Click" />
    </div>

        <!-- Orders Table -->
 <asp:Panel ID="pnlOrders" runat="server">
          <table class="order-table">
 <thead>
            <tr>
           <th>Order ID</th>
  <th>Type</th>
      <th>Customer</th>
    <th>Time</th>
                 <th>Items</th>
   <th>Total</th>
    <th>Status</th>
      <th>Actions</th>
   </tr>
       </thead>
     <tbody>
       <asp:Repeater ID="rptOrders" runat="server" OnItemCommand="rptOrders_ItemCommand" OnItemDataBound="rptOrders_ItemDataBound">
 <ItemTemplate>
    <tr>
  <td>
 <a href='OrderDetails.aspx?orderId=<%# Eval("OrderID") %>' style='text-decoration:none;'>
 <span class="order-id">#<%# Eval("OrderID") %></span>
 </a>
</td>
       <td><span class="order-type-badge badge-<%# GetOrderTypeCss(Eval("OrderType").ToString()) %>"><%# Eval("OrderType") %></span></td>
 <td><%# Eval("CustomerName") %></td>
      <td><%# Eval("OrderDate", "{0:hh:mm tt}") %></td>
         <td><%# GetItemCount(Convert.ToInt32(Eval("OrderID"))) %> item(s)</td>
      <td><strong>PHP <%# Eval("TotalAmount", "{0:N2}") %></strong></td>
    <td>
        <asp:HiddenField ID="hfOrderId" runat="server" Value='<%# Eval("OrderID") %>' />
    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="status-dropdown" 
       SelectedValue='<%# Eval("OrderStatus") %>' OnSelectedIndexChanged="StatusChanged" AutoPostBack="true">
       <asp:ListItem Value="Pending">Pending</asp:ListItem>
          <asp:ListItem Value="Approved">Approved</asp:ListItem>
   <asp:ListItem Value="Completed">Completed</asp:ListItem>
   <asp:ListItem Value="Cancelled">Cancelled</asp:ListItem>
             </asp:DropDownList>
            </td>
    <td>
         <div class="action-buttons">
          <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn-sm btn-delete" 
      CommandName="Delete" CommandArgument='<%# Eval("OrderID") %>' 
      OnClientClick="return confirm('Are you sure you want to delete this order?');" />
  </div>
           </td>
   </tr>
      </ItemTemplate>
            </asp:Repeater>
          </tbody>
  </table>
      </asp:Panel>

   <!-- Empty State -->
  <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
      <div class="empty-state">
          <i class="bi bi-inbox"></i>
  <h4>No Orders Found</h4>
           <p>There are no orders for today matching your criteria.</p>
 <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn btn-primary mt-3">
   <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
   </asp:LinkButton>
          </div>
     </asp:Panel>
 </div>

        <%-- Hidden button for auto-refresh postback --%>
        <asp:Button ID="btnRefreshHidden" runat="server" OnClick="btnRefreshHidden_Click" style="display:none;" />
    </form>
  
 <script src="Scripts/app.js"></script>
    <script>
   // Auto-refresh every 30 seconds
        setInterval(function () {
   if (typeof __doPostBack === 'function') {
   __doPostBack('<%= btnRefreshHidden.UniqueID %>', '');
  }
  }, 30000);
    </script>
</body>
</html>
