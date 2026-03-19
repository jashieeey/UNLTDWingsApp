<%@ Page Title="Sales Reports" Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="UNLTDWingsApp.Reports" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sales Reports - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
   body {
            background-color: #F5F0EB;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  min-height: 100vh;
   }
        .header {
      background: linear-gradient(135deg, #3D2314 0%, #5E2D10 100%);
       padding: 15px 20px;
         display: flex;
 align-items: center;
   gap: 15px;
        }
 .back-btn { color: white; font-size: 1.5rem; text-decoration: none; }
        .page-title { color: white; font-size: 18px; font-weight: 700; flex: 1; }
   .content { padding: 20px; }
   .section {
     background: white;
    border-radius: 15px;
     padding: 20px;
            margin-bottom: 15px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
   opacity: 0;
     animation: fadeInUp 0.4s ease forwards;
        }
        .section:nth-child(1) { animation-delay: 0.1s; }
  .section:nth-child(2) { animation-delay: 0.2s; }
   .section:nth-child(3) { animation-delay: 0.3s; }
 .section-title {
      color: #5E2D10;
            font-size: 16px;
     font-weight: 700;
      margin-bottom: 15px;
 display: flex;
align-items: center;
          gap: 8px;
        }
        .form-label { color: #5E2D10; font-weight: 600; font-size: 13px; margin-bottom: 5px; }
        .form-control {
            border: 2px solid #E8D5B5;
   border-radius: 10px;
  padding: 10px 15px;
            font-size: 14px;
 transition: border-color 0.3s ease;
        }
        .form-control:focus { border-color: #5E2D10; box-shadow: 0 0 0 2px rgba(94, 45, 16, 0.1); }
        .btn-generate {
background: linear-gradient(135deg, #5E2D10 0%, #8B4513 100%);
 color: white;
   border: none;
     border-radius: 10px;
    padding: 12px 25px;
     font-weight: 600;
      transition: all 0.3s ease;
 }
        .btn-generate:hover { background: linear-gradient(135deg, #4a230c 0%, #6B3410 100%); color: white; transform: translateY(-2px); }
        /* Summary Cards */
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
   margin-bottom: 20px;
  }
     .summary-card {
      background: linear-gradient(135deg, #5E2D10 0%, #8B4513 100%);
       color: white;
   border-radius: 15px;
       padding: 20px;
  text-align: center;
        }
        .summary-card.highlight {
  grid-column: span 2;
         background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
        }
        .summary-value { font-size: 28px; font-weight: 700; }
        .summary-label { font-size: 12px; opacity: 0.9; margin-top: 5px; }
        /* Table */
        .report-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .report-table th {
     background: #5E2D10;
   color: white;
      padding: 12px;
   text-align: left;
   font-size: 13px;
      }
        .report-table td { padding: 12px; border-bottom: 1px solid #F0E8E0; font-size: 13px; }
        .report-table tr:hover { background: #FDF8F0; }
   .amount { font-weight: 700; color: #C4773B; }
        .status-badge { padding: 3px 10px; border-radius: 10px; font-size: 11px; font-weight: 600; }
        .status-paid { background: #d4edda; color: #155724; }
      .status-pending { background: #fff3cd; color: #856404; }
    /* Quick Stats */
        .quick-stats { display: flex; gap: 15px; margin-bottom: 20px; flex-wrap: wrap; }
        .quick-stat {
 background: white;
  border-radius: 12px;
    padding: 15px 20px;
  flex: 1;
    min-width: 140px;
text-align: center;
       box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .quick-stat-value { font-size: 20px; font-weight: 700; color: #5E2D10; }
   .quick-stat-label { font-size: 11px; color: #888; }
        /* Top Items */
        .top-item {
display: flex;
     align-items: center;
 padding: 10px 0;
  border-bottom: 1px solid #F0E8E0;
     gap: 10px;
        }
 .top-item:last-child { border-bottom: none; }
 .top-rank {
      width: 30px;
        height: 30px;
   background: #5E2D10;
     color: white;
  border-radius: 50%;
    display: flex;
 justify-content: center;
 align-items: center;
       font-weight: 700;
    font-size: 12px;
      }
.top-rank.gold { background: #FFD700; color: #5E2D10; }
        .top-rank.silver { background: #C0C0C0; color: #333; }
  .top-rank.bronze { background: #CD7F32; color: white; }
        .top-name { flex: 1; font-weight: 600; font-size: 14px; }
  .top-qty { color: #888; font-size: 13px; }
   
    @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Loading Overlay -->
        <div id="loadingOverlay" class="loading-overlay">
            <div style="text-align: center;">
 <div class="loading-spinner"></div>
      <div class="loading-text">Generating report...</div>
            </div>
        </div>
        
        <div class="header">
            <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="back-btn">
      <i class="bi bi-arrow-left"></i>
       </asp:LinkButton>
 <span class="page-title">Sales Reports</span>
    </div>

        <div class="content">
    <!-- Date Filter -->
<div class="section">
       <div class="section-title">
        <i class="bi bi-calendar-range"></i>
     Select Date Range
  </div>
          <div class="row g-3 align-items-end">
      <div class="col">
       <label class="form-label">Start Date</label>
             <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
    </div>
    <div class="col">
        <label class="form-label">End Date</label>
    <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
    </div>
         <div class="col-auto">
  <asp:Button ID="btnGenerate" runat="server" Text="Generate Report" CssClass="btn-generate" OnClick="btnGenerate_Click" OnClientClick="showLoading();" />
     </div>
     </div>
        </div>

            <!-- Quick Stats -->
            <div class="quick-stats">
             <div class="quick-stat">
   <div class="quick-stat-value">PHP <asp:Label ID="lblTodaySales" runat="server" Text="0"></asp:Label></div>
             <div class="quick-stat-label">Today's Sales</div>
     </div>
  <div class="quick-stat">
  <div class="quick-stat-value"><asp:Label ID="lblTodayOrders" runat="server" Text="0"></asp:Label></div>
      <div class="quick-stat-label">Orders Today</div>
             </div>
     <div class="quick-stat">
        <div class="quick-stat-value">PHP <asp:Label ID="lblWeekSales" runat="server" Text="0"></asp:Label></div>
            <div class="quick-stat-label">This Week</div>
           </div>
     <div class="quick-stat">
      <div class="quick-stat-value">PHP <asp:Label ID="lblMonthSales" runat="server" Text="0"></asp:Label></div>
       <div class="quick-stat-label">This Month</div>
          </div>
         </div>

 <!-- Report Results -->
   <asp:Panel ID="pnlReport" runat="server" Visible="false">
          <!-- Summary Cards -->
    <div class="summary-grid">
           <div class="summary-card highlight">
         <div class="summary-value">PHP <asp:Label ID="lblTotalSales" runat="server" Text="0"></asp:Label></div>
    <div class="summary-label">Total Sales</div>
 </div>
       <div class="summary-card">
                <div class="summary-value"><asp:Label ID="lblTotalOrders" runat="server" Text="0"></asp:Label></div>
         <div class="summary-label">Total Orders</div>
        </div>
     <div class="summary-card">
      <div class="summary-value">PHP <asp:Label ID="lblAvgOrder" runat="server" Text="0"></asp:Label></div>
     <div class="summary-label">Avg Order Value</div>
           </div>
          </div>

  <!-- Top Selling Items -->
      <div class="section">
   <div class="section-title">
  <i class="bi bi-trophy"></i>
         Top Selling Items
  </div>
            <asp:Repeater ID="rptTopItems" runat="server">
   <ItemTemplate>
         <div class="top-item">
           <div class='<%# GetRankClass(Container.ItemIndex) %>'><%# Container.ItemIndex + 1 %></div>
       <div class="top-name"><%# Eval("ItemName") %></div>
         <div class="top-qty"><%# Eval("TotalQty") %> sold</div>
        </div>
           </ItemTemplate>
       </asp:Repeater>
          </div>

          <!-- Orders Table -->
     <div class="section">
  <div class="section-title">
        <i class="bi bi-receipt"></i>
  Order Details
         </div>
            <div style="overflow-x: auto;">
        <table class="report-table">
               <thead>
            <tr>
          <th>Order #</th>
         <th>Date</th>
       <th>Customer</th>
 <th>Type</th>
           <th>Payment</th>
    <th>Status</th>
       <th>Amount</th>
          </tr>
          </thead>
     <tbody>
      <asp:Repeater ID="rptOrders" runat="server">
      <ItemTemplate>
         <tr>
     <td><strong>#<%# Eval("OrderID") %></strong></td>
           <td><%# Eval("OrderDate", "{0:MMM dd, yyyy}") %></td>
        <td><%# Eval("CustomerName") %></td>
          <td><%# Eval("OrderType") %></td>
        <td><%# Eval("PaymentMethod") %></td>
    <td>
                <span class='<%# Eval("PaymentStatus").ToString() == "Paid" ? "status-badge status-paid" : "status-badge status-pending" %>'>
           <%# Eval("PaymentStatus") %>
          </span>
           </td>
    <td class="amount">PHP <%# Eval("TotalAmount", "{0:N2}") %></td>
      </tr>
          </ItemTemplate>
  </asp:Repeater>
        </tbody>
        </table>
       </div>
   </div>
            </asp:Panel>
      </div>
    </form>
    
    <script src="Scripts/app.js"></script>
    <script>
        function showLoading() {
   document.getElementById('loadingOverlay').classList.add('active');
        }
        
document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('loadingOverlay').classList.remove('active');
        });
    </script>
</body>
</html>
