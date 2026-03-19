<%@ Page Title="Order Entry" Language="C#" AutoEventWireup="true" CodeBehind="OrderEntry.aspx.cs" Inherits="UNLTDWingsApp.OrderEntry" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Order Entry - UNLTD Wings</title>
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
    /* Header */
        .header {
 background: linear-gradient(135deg, #3D2314 0%, #5E2D10 100%);
            padding: 15px 20px;
       display: flex;
         align-items: center;
  gap: 15px;
        }
        .back-btn { color: white; font-size: 1.5rem; text-decoration: none; }
        .page-title { color: white; font-size: 18px; font-weight: 700; flex: 1; }
        .order-type-badge {
            background: rgba(255,255,255,0.2);
padding: 5px 15px;
   border-radius: 15px;
     font-size: 12px;
         color: white;
        }
        /* Content */
        .content { padding: 20px; padding-bottom: 100px; }
        /* Section */
        .section {
            background: white;
     border-radius: 15px;
      padding: 20px;
            margin-bottom: 15px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            animation: fadeInUp 0.4s ease forwards;
    opacity: 0;
        }
        .section:nth-child(1) { animation-delay: 0.1s; }
        .section:nth-child(2) { animation-delay: 0.2s; }
        .section:nth-child(3) { animation-delay: 0.3s; }
   .section-title {
            color: #5E2D10;
      font-size: 15px;
            font-weight: 700;
            margin-bottom: 15px;
       display: flex;
         align-items: center;
            gap: 8px;
  }
        /* Form inputs */
        .form-control, .form-select {
            border: 2px solid #E8D5B5;
      border-radius: 10px;
            padding: 12px 15px;
         font-size: 14px;
         transition: border-color 0.3s ease;
        }
      .form-control:focus, .form-select:focus {
  border-color: #5E2D10;
   box-shadow: 0 0 0 2px rgba(94, 45, 16, 0.1);
        }
     /* Add item row */
        .add-item-row { display: flex; gap: 10px; margin-bottom: 10px; }
        .add-item-row .form-select { flex: 1; }
        .add-item-row .qty-input { width: 80px; }
     .btn-add {
            background: #5E2D10;
      color: white;
   border: none;
            border-radius: 10px;
     padding: 12px 20px;
 font-weight: 600;
        transition: all 0.3s ease;
        }
  .btn-add:hover { background: #4a230c; color: white; transform: translateY(-2px); }
        /* Cart items */
        .cart-item {
         display: flex;
     justify-content: space-between;
            align-items: center;
       padding: 12px 0;
          border-bottom: 1px solid #F0E8E0;
            animation: fadeIn 0.3s ease forwards;
        }
        .cart-item:last-child { border-bottom: none; }
     .cart-item-name { font-weight: 600; font-size: 14px; color: #2C2C2C; }
        .cart-item-qty { color: #888; font-size: 13px; }
.cart-item-subtotal { font-weight: 700; color: #C4773B; }
        /* Total */
    .total-row {
            display: flex;
            justify-content: space-between;
       align-items: center;
            padding: 15px 0;
  margin-top: 10px;
            border-top: 2px solid #5E2D10;
        }
 .total-label { font-size: 18px; font-weight: 700; color: #5E2D10; }
        .total-value { font-size: 24px; font-weight: 700; color: #C4773B; }
  /* Buttons */
   .btn-checkout {
  background: linear-gradient(135deg, #5E2D10 0%, #8B4513 100%);
   color: white;
     border: none;
        border-radius: 15px;
      padding: 15px;
       font-size: 16px;
     font-weight: 700;
      width: 100%;
  position: fixed;
       bottom: 20px;
   left: 20px;
            right: 20px;
         width: calc(100% - 40px);
            max-width: 500px;
            margin: 0 auto;
         box-shadow: 0 4px 20px rgba(94, 45, 16, 0.3);
    transition: all 0.3s ease;
        }
        .btn-checkout:hover {
   background: linear-gradient(135deg, #4a230c 0%, #6B3410 100%);
            color: white;
    transform: translateY(-2px);
        }
        /* Message */
        .message {
     padding: 12px;
          border-radius: 10px;
            text-align: center;
            font-weight: 600;
            margin-top: 10px;
    animation: fadeInScale 0.3s ease forwards;
        }
        .message.success { background: #d4edda; color: #155724; }
        .message.error { background: #f8d7da; color: #721c24; }
      /* Empty cart */
        .empty-cart { text-align: center; padding: 30px; color: #888; }
        .empty-cart i { font-size: 3rem; margin-bottom: 10px; color: #D4C4B0; }
   
        @keyframes fadeInUp {
    from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeIn {
    from { opacity: 0; }
            to { opacity: 1; }
        }
    @keyframes fadeInScale {
 from { opacity: 0; transform: scale(0.9); }
  to { opacity: 1; transform: scale(1); }
   }
 </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Loading Overlay -->
        <div id="loadingOverlay" class="loading-overlay">
            <div style="text-align: center;">
     <div class="loading-spinner"></div>
   <div class="loading-text">Processing order...</div>
   </div>
        </div>
        
     <!-- Header -->
        <div class="header">
        <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="back-btn">
                <i class="bi bi-arrow-left"></i>
      </asp:LinkButton>
  <span class="page-title">New Order</span>
            <span class="order-type-badge"><asp:Label ID="lblOrderType" runat="server" Text="Walk-in"></asp:Label></span>
    </div>

        <!-- Content -->
   <div class="content">
            <!-- Customer Details -->
<div class="section">
           <div class="section-title">
    <i class="bi bi-person-lines-fill"></i>
         Customer Details
  </div>

 <!-- Dine-in: select table only (no name required) -->
 <asp:Panel ID="pnlDineIn" runat="server" Visible="false">
 <div class="mb-3">
 <label class="form-label fw-bold" style="color: #5E2D10;">Table Number *</label>
 <asp:DropDownList ID="ddlTableNumber" runat="server" CssClass="form-select">
 <asp:ListItem Text="Select table..." Value=""></asp:ListItem>
 <asp:ListItem Text="Table1" Value="1"></asp:ListItem>
 <asp:ListItem Text="Table2" Value="2"></asp:ListItem>
 <asp:ListItem Text="Table3" Value="3"></asp:ListItem>
 <asp:ListItem Text="Table4" Value="4"></asp:ListItem>
 <asp:ListItem Text="Table5" Value="5"></asp:ListItem>
 </asp:DropDownList>
 </div>
 </asp:Panel>

 <!-- Takeout/Delivery: name + optional fields based on type -->
 <asp:Panel ID="pnlCustomer" runat="server" Visible="true">
 <div class="mb-3">
 <asp:TextBox ID="txtCustomerName" runat="server" CssClass="form-control" placeholder="Customer Full Name *"></asp:TextBox>
 </div>

 <asp:Panel ID="pnlDeliveryFields" runat="server" Visible="false">
 <div class="mb-3">
 <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" placeholder="Delivery Address *"></asp:TextBox>
 </div>
 <div class="mb-3">
 <asp:TextBox ID="txtContact" runat="server" CssClass="form-control" placeholder="Contact Number *"></asp:TextBox>
 </div>
 </asp:Panel>
 </asp:Panel>
</div>

<!-- Payment Method -->
<div class="mt-3">
 <label class="form-label fw-bold" style="color: #5E2D10;">Payment Method</label>
 <asp:DropDownList ID="ddlPaymentMethod" runat="server" CssClass="form-select" onchange="toggleGcashRef();">
 <asp:ListItem Text="Cash" Value="Cash"></asp:ListItem>
 <asp:ListItem Text="GCash" Value="GCash"></asp:ListItem>
 </asp:DropDownList>
</div>

<asp:Panel ID="pnlGcashRef" runat="server" Style="display:none;" CssClass="mt-2">
 <label class="form-label fw-bold" style="color: #5E2D10;">GCash Reference No. *</label>
 <asp:TextBox ID="txtGcashReference" runat="server" CssClass="form-control" placeholder="Paste your reference no here"></asp:TextBox>
</asp:Panel>

       <!-- Add Items -->
  <div class="section">
       <div class="section-title">
         <i class="bi bi-plus-circle-fill"></i>
          Add Items
           </div>
    <div class="add-item-row">
 <asp:DropDownList ID="ddlMenu" runat="server" CssClass="form-select">
        </asp:DropDownList>
            <asp:TextBox ID="txtQuantity" runat="server" CssClass="form-control qty-input" TextMode="Number" min="1" Text="1"></asp:TextBox>
       </div>
     <asp:Button ID="btnAddItem" runat="server" Text="Add to Order" CssClass="btn-add w-100" OnClick="btnAddItem_Click" />
        <asp:Label ID="lblMenuError" runat="server" CssClass="d-block mt-2 text-center" ForeColor="Red" Font-Size="Small"></asp:Label>
       </div>

       <!-- Current Order -->
  <div class="section">
   <div class="section-title">
             <i class="bi bi-cart-check-fill"></i>
         Current Order
   </div>
 
        <asp:Panel ID="pnlCartItems" runat="server">
      <asp:Repeater ID="rptCart" runat="server">
        <ItemTemplate>
       <div class="cart-item">
  <div>
        <div class="cart-item-name"><%# Eval("ItemName") %></div>
         <div class="cart-item-qty">x<%# Eval("Quantity") %> @ PHP <%# Eval("Price", "{0:N2}") %></div>
     </div>
                 <div class="cart-item-subtotal">PHP <%# Eval("Subtotal", "{0:N2}") %></div>
        </div>
       </ItemTemplate>
   </asp:Repeater>
     
  <div class="total-row">
         <span class="total-label">Total</span>
  <asp:Label ID="lblTotal" runat="server" CssClass="total-value" Text="PHP 0.00"></asp:Label>
   </div>
            </asp:Panel>

       <asp:Panel ID="pnlEmptyCart" runat="server" CssClass="empty-cart">
                <i class="bi bi-cart-x d-block"></i>
    <p>No items added yet</p>
     </asp:Panel>

       <asp:Label ID="lblCheckoutMsg" runat="server" CssClass="message" Visible="false"></asp:Label>
            </div>
        </div>

        <!-- Checkout Button -->
        <asp:Button ID="btnCheckout" runat="server" Text="Confirm & Checkout" CssClass="btn-checkout" OnClick="btnCheckout_Click" OnClientClick="showLoading();" />
    </form>
    
    <script src="Scripts/app.js"></script>
    <script>
 function showLoading() {
       document.getElementById('loadingOverlay').classList.add('active');
        }

 function toggleGcashRef() {
 var ddl = document.getElementById('<%= ddlPaymentMethod.ClientID %>');
 var pnl = document.getElementById('<%= pnlGcashRef.ClientID %>');
 if (!ddl || !pnl) return;
 pnl.style.display = (ddl.value === 'GCash') ? 'block' : 'none';
 }

        document.addEventListener('DOMContentLoaded', function() {
 document.getElementById('loadingOverlay').classList.remove('active');
 toggleGcashRef();
 });
    </script>
</body>
</html>