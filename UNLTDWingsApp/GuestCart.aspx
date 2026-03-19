<%@ Page Title="My Cart" Language="C#" AutoEventWireup="true" CodeBehind="GuestCart.aspx.cs" Inherits="UNLTDWingsApp.GuestCart" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Cart - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body class="unltd-dark">
    <form id="form1" runat="server">
  <!-- Loading Overlay -->
        <div id="loadingOverlay" class="loading-overlay">
        <div style="text-align: center;">
    <div class="loading-spinner"></div>
    <div class="loading-text">Processing order...</div>
            </div>
      </div>
   
 <!-- Header -->
        <div class="unltd-header">
     <div class="unltd-header__row mb-3">
     <div class="unltd-brand">
    <i class="bi bi-fire text-warning me-2"></i>
            <span>UNLTD</span> WINGS
      </div>
    <div class="d-flex align-items-center text-white">
            <div class="me-2 text-end lh-1">
           <asp:Label ID="lblAccountType" runat="server" Text="Guest" CssClass="d-block text-white-50" style="font-size:11px"></asp:Label>
 <asp:Label ID="lblGuestName" runat="server" Text="Guest" CssClass="fw-bold" style="font-size:14px"></asp:Label>
         </div>
   <div class="rounded-circle bg-warning d-flex align-items-center justify-content-center text-dark fw-bold" style="width:35px;height:35px">
    <i class="bi bi-person-fill"></i>
  </div>
          <asp:LinkButton ID="btnLogout" runat="server" CssClass="ms-3 text-white-50 hover-text-white" OnClick="btnLogout_Click" ToolTip="Exit">
      <i class="bi bi-box-arrow-right fs-5"></i>
   </asp:LinkButton>
    </div>
   </div>
      
    <!-- Navigation Tabs -->
     <div class="d-flex gap-2">
             <a href="GuestMenu.aspx" class="btn btn-outline-light w-100 py-2 d-flex align-items-center justify-content-center" style="border-radius:50px">
        <i class="bi bi-menu-button-wide me-2"></i> Menu
 </a>
     <a href="GuestCart.aspx" class="unltd-btn w-100 py-2 d-flex align-items-center justify-content-center">
        <i class="bi bi-cart3 me-2"></i> Cart
          </a>
    <a href="GuestOrders.aspx" class="btn btn-outline-light w-100 py-2 d-flex align-items-center justify-content-center" style="border-radius:50px">
        <i class="bi bi-receipt me-2"></i> Orders
          </a>
    </div>
 </div>

        <!-- Cart Section -->
      <div class="unltd-container pb-5">
        <!-- Success Message -->
     <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="unltd-card bg-success bg-opacity-25 border-success text-center">
    <i class="bi bi-check-circle-fill text-success fs-1 mb-2"></i>
   <h5 class="text-success fw-bold">Order Submitted Successfully!</h5>
  <p class="text-white-50">Your order has been sent to staff for approval.</p>
 <div class="mt-3">
 <a href="GuestOrders.aspx" class="unltd-btn">Check My Orders</a>
 </div>
</asp:Panel>

   <!-- Cart Items -->
    <asp:Panel ID="pnlCart" runat="server">
        <h5 class="unltd-title"><i class="bi bi-cart-check me-2"></i>Your Cart</h5>
        
       <asp:Repeater ID="rptCartItems" runat="server" OnItemCommand="rptCartItems_ItemCommand">
   <ItemTemplate>
   <div class="unltd-card unltd-card--accent d-flex align-items-center gap-3">
    <div class="d-flex align-items-center justify-content-center bg-dark rounded-3" style="width:60px;height:60px;flex-shrink:0">
          <i class="bi bi-fire text-warning fs-3"></i>
       </div>
   <div class="flex-grow-1">
              <div class="fw-bold text-white"><%# Eval("ItemName") %></div>
           <div class="text-white-50 small">PHP <%# Eval("Price", "{0:N2}") %></div>
        <div class="text-warning fw-bold">PHP <%# Eval("Subtotal", "{0:N2}") %></div>
          </div>
<div class="d-flex align-items-center gap-2">
           <asp:LinkButton ID="btnDecrease" runat="server" CssClass="btn btn-dark border-secondary btn-sm text-white" 
  CommandName="Decrease" CommandArgument='<%# Eval("ItemID") %>' style="width:30px;height:30px">-</asp:LinkButton>
   <span class="text-white fw-bold" style="min-width:20px;text-align:center"><%# Eval("Quantity") %></span>
          <asp:LinkButton ID="btnIncrease" runat="server" CssClass="btn btn-dark border-secondary btn-sm text-white" 
           CommandName="Increase" CommandArgument='<%# Eval("ItemID") %>' style="width:30px;height:30px">+</asp:LinkButton>
          </div>
            <asp:LinkButton ID="btnRemove" runat="server" CssClass="btn p-0 text-danger ms-2" 
CommandName="Remove" CommandArgument='<%# Eval("ItemID") %>' ToolTip="Remove item">
 <i class="bi bi-trash fs-5"></i>
    </asp:LinkButton>
          </div>
        </ItemTemplate>
           </asp:Repeater>

                <!-- Guest Details / Delivery Details -->
         <div class="unltd-card p-3">
      <label class="text-warning fw-bold small text-uppercase mb-3"><i class="bi bi-person me-2"></i>Order Details</label>
    <div class="mb-3 text-white-50 small">Order type: <strong><asp:Label ID="lblOrderType" runat="server" Text="Takeout" CssClass="text-white"></asp:Label></strong></div>
      
      <!-- Table accounts (Dine-in) don't need name/contact/address -->
  <asp:Panel ID="pnlGuestFields" runat="server" Visible="true">
      <asp:TextBox ID="txtGuestName" runat="server" CssClass="form-control bg-dark text-white border-secondary mb-2" placeholder="Your Full Name *"></asp:TextBox>
      <asp:Panel ID="pnlContactField" runat="server" Visible="true">
  <asp:TextBox ID="txtContact" runat="server" CssClass="form-control bg-dark text-white border-secondary mb-2" placeholder="Contact Number *"></asp:TextBox>
      </asp:Panel>
      <asp:Panel ID="pnlAddress" runat="server" Visible="false">
    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control bg-dark text-white border-secondary mb-2" placeholder="Delivery Address *"></asp:TextBox>
      </asp:Panel>
      </asp:Panel>

    <!-- Table account dine-in info -->
      <asp:Panel ID="pnlTableInfo" runat="server" Visible="false">
      <div class="bg-dark rounded p-3 mb-2 border border-secondary">
      <div class="text-white-50 small mb-1">Dine-in</div>
   <div class="text-warning fw-bold fs-5"><i class="bi bi-table me-2"></i>Table <asp:Label ID="lblTableNum" runat="server" Text=""></asp:Label></div>
</div>
      </asp:Panel>

  <div class="mt-3">
      <label class="text-warning fw-bold small text-uppercase mb-2">
      <i class="bi bi-cash-coin me-2"></i>Payment Method
      </label>
      <asp:DropDownList ID="ddlPaymentMethod" runat="server" CssClass="form-select bg-dark text-white border-secondary" AutoPostBack="true" OnSelectedIndexChanged="ddlPaymentMethod_SelectedIndexChanged">
      <asp:ListItem Text="Cash" Value="Cash"></asp:ListItem>
      <asp:ListItem Text="GCash" Value="GCash"></asp:ListItem>
      </asp:DropDownList>
      </div>

      <asp:Panel ID="pnlGcash" runat="server" Visible="false" CssClass="mt-3 bg-dark p-3 rounded border border-warning border-opacity-25">
   <div class="text-white-50 small mb-2">
      <i class="bi bi-exclamation-triangle text-warning me-1"></i>
      For GCash payment, please pay your exact amount to the GCash number below and include your reference number.
 </div>
      <div class="text-warning fw-bold mb-2 fs-5"><i class="bi bi-phone me-1"></i> GCash No: 09XXXXXXXXX</div>
      <asp:TextBox ID="txtGcashReference" runat="server" CssClass="form-control bg-black text-white border-secondary" placeholder="Paste your reference no here *"></asp:TextBox>
      <div class="text-danger small mt-1" id="gcashValidation" style="display:none;"><i class="bi bi-exclamation-circle me-1"></i>Reference number is required for GCash payments.</div>
      </asp:Panel>
         </div>

                <!-- Order Summary -->
     <div class="unltd-card overflow-hidden p-0 mt-3">
         <div class="p-3">
     <div class="d-flex justify-content-between mb-2">
       <span class="text-white-50">Subtotal</span>
        <asp:Label ID="lblSubtotal" runat="server" CssClass="text-white fw-bold" Text="PHP 0.00"></asp:Label>
        </div>
         <div class="d-flex justify-content-between">
                 <span class="text-white-50">Items</span>
  <asp:Label ID="lblItemCount" runat="server" CssClass="text-white fw-bold" Text="0 items"></asp:Label>
 </div>
 </div>
 <div class="bg-dark p-3 d-flex justify-content-between align-items-center">
      <span class="text-white fs-5 fw-bold">Total</span>
   <asp:Label ID="lblTotal" runat="server" CssClass="text-warning fs-4 fw-bold" Text="PHP 0.00"></asp:Label>
   </div>
                </div>

                <!-- Submit Button -->
    <asp:Button ID="btnSubmitOrder" runat="server" Text="Submit Order Request" CssClass="unltd-btn w-100 py-3 mt-3 fs-5" OnClick="btnSubmitOrder_Click" OnClientClick="showLoading();" />
        <asp:Label ID="lblMessage" runat="server" CssClass="text-danger text-center d-block mt-3 fw-bold"></asp:Label>
            </asp:Panel>

    <!-- Empty Cart -->
            <asp:Panel ID="pnlEmptyCart" runat="server" Visible="false" CssClass="unltd-empty">
      <i class="bi bi-cart-x unltd-empty__icon"></i>
       <h4 class="unltd-empty__title">Your cart is empty</h4>
          <p class="unltd-empty__text">Browse our menu and add some delicious items!</p>
          <a href="GuestMenu.aspx" class="unltd-btn mt-3 d-inline-block">
 <i class="bi bi-arrow-left me-2"></i>Back to Menu
     </a>
            </asp:Panel>
        </div>
    </form>
    
    <script src="Scripts/app.js"></script>
    <script>
function showLoading() {
       document.getElementById('loadingOverlay').classList.add('active');
        }
      
        document.addEventListener('DOMContentLoaded', function() {
       if(typeof AppLoader !== 'undefined') AppLoader.hide();
        });
    </script>
</body>
</html>
