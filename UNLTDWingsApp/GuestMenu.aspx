<%@ Page Title="Menu" Language="C#" AutoEventWireup="true" CodeBehind="GuestMenu.aspx.cs" Inherits="UNLTDWingsApp.GuestMenu" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Menu - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body class="unltd-dark">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
     
        <!-- Loading Overlay -->
        <div id="loadingOverlay" class="loading-overlay">
            <div style="text-align: center;">
      <div class="loading-spinner"></div>
      <div class="loading-text">Loading menu...</div>
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
    <a href="GuestMenu.aspx" class="unltd-btn w-100 py-2 d-flex align-items-center justify-content-center">
        <i class="bi bi-menu-button-wide me-2"></i> Menu
          </a>
          <a href="GuestCart.aspx" class="btn btn-outline-light w-100 py-2 d-flex align-items-center justify-content-center" style="border-radius:50px">
       <i class="bi bi-cart3 me-2"></i> Cart
         </a>
          <a href="GuestOrders.aspx" class="btn btn-outline-light w-100 py-2 d-flex align-items-center justify-content-center" style="border-radius:50px">
       <i class="bi bi-receipt me-2"></i> Orders
         </a>
            </div>
      </div>

        <!-- Category Filter -->
        <div class="bg-dark border-bottom border-secondary p-3">
         <div class="d-flex gap-2 overflow-auto pb-1" style="-webkit-overflow-scrolling:touch; scrollbar-width:none;">
     <asp:LinkButton ID="btnAll" runat="server" CssClass="category-btn active" OnClick="btnCategory_Click" CommandArgument="All">
         <i class="bi bi-grid-fill me-1"></i>All
                </asp:LinkButton>
   <asp:LinkButton ID="btnUnlimited" runat="server" CssClass="category-btn" OnClick="btnCategory_Click" CommandArgument="Unlimited">
      <i class="bi bi-infinity me-1"></i>Unlimited
        </asp:LinkButton>
       <asp:LinkButton ID="btnWings" runat="server" CssClass="category-btn" OnClick="btnCategory_Click" CommandArgument="Wings">
     <i class="bi bi-fire me-1"></i>Wings
     </asp:LinkButton>
     <asp:LinkButton ID="btnRiceMeals" runat="server" CssClass="category-btn" OnClick="btnCategory_Click" CommandArgument="Rice Meals">
   <i class="bi bi-egg-fried me-1"></i>Rice Meals
     </asp:LinkButton>
   <asp:LinkButton ID="btnPasta" runat="server" CssClass="category-btn" OnClick="btnCategory_Click" CommandArgument="Pasta">
     <i class="bi bi-cup-hot me-1"></i>Pasta
    </asp:LinkButton>
    <asp:LinkButton ID="btnCombos" runat="server" CssClass="category-btn" OnClick="btnCategory_Click" CommandArgument="Combos">
     <i class="bi bi-box2-fill me-1"></i>Combos
        </asp:LinkButton>
       <asp:LinkButton ID="btnFries" runat="server" CssClass="category-btn" OnClick="btnCategory_Click" CommandArgument="Fries">
        <i class="bi bi-basket-fill me-1"></i>Fries
  </asp:LinkButton>
      <asp:LinkButton ID="btnDrinks" runat="server" CssClass="category-btn" OnClick="btnCategory_Click" CommandArgument="Drinks">
        <i class="bi bi-cup-straw me-1"></i>Drinks
     </asp:LinkButton>
     <asp:LinkButton ID="btnAddons" runat="server" CssClass="category-btn" OnClick="btnCategory_Click" CommandArgument="Add-ons">
  <i class="bi bi-plus-circle me-1"></i>Add-ons
      </asp:LinkButton>
         </div>
        </div>

        <!-- Menu Items -->
  <div class="unltd-container pb-5 mb-5">

       <!-- Top Favourites Highlight -->
       <div class="mb-3">
           <h6 class="text-warning fw-bold mb-2"><i class="bi bi-star-fill me-1"></i> TOP FAVOURITES</h6>
           <div class="d-flex gap-2 overflow-auto pb-2" style="-webkit-overflow-scrolling:touch; scrollbar-width:none;">
               <asp:Repeater ID="rptTopFavourites" runat="server" OnItemCommand="rptMenuItems_ItemCommand">
     <ItemTemplate>
     <div class="bg-dark rounded-3 p-2 border border-warning border-opacity-25 text-center flex-shrink-0" style="width:120px;">
           <div class="rounded-2 overflow-hidden mb-1" style="height:70px;">
          <img src='<%# GetImageUrl(Eval("ImageUrl"), Eval("ItemCategory").ToString()) %>' alt='<%# Eval("ItemName") %>' style="width:100%;height:100%;object-fit:cover" onerror="this.style.display='none';" />
       </div>
            <div class="text-white small fw-bold text-truncate" style="font-size:11px;"><%# Eval("ItemName") %></div>
    <div class="text-warning fw-bold small">PHP <%# Eval("Price", "{0:N0}") %></div>
     <asp:LinkButton ID="btnAddFav" runat="server" CssClass="btn btn-warning btn-sm text-white w-100 mt-1 fw-bold" style="font-size:11px; border-radius:15px;" CommandName="AddToCart" CommandArgument='<%# Eval("ItemID") + "," + Eval("ItemName") + "," + Eval("Price") %>'>
          <i class="bi bi-plus"></i> Add
                 </asp:LinkButton>
            </div>
         </ItemTemplate>
 </asp:Repeater>
           </div>
       </div>

       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
          <ContentTemplate>
      <asp:Repeater ID="rptMenuItems" runat="server" OnItemCommand="rptMenuItems_ItemCommand">
     <ItemTemplate>
    <div class='unltd-card unltd-card--accent d-flex align-items-center gap-3 p-3'>
         <div class='rounded-3 overflow-hidden d-flex align-items-center justify-content-center bg-dark' style="width:75px;height:75px;flex-shrink:0;">
              <img src='<%# GetImageUrl(Eval("ImageUrl"), Eval("ItemCategory").ToString()) %>' 
 alt='<%# Eval("ItemName") %>' 
 style="width:100%;height:100%;object-fit:cover"
      onerror="this.style.display='none'; this.nextElementSibling.style.display='block';" />
            <i class='<%# GetCategoryIcon(Eval("ItemCategory").ToString()) %> fs-2 text-secondary' style="display:none;"></i>
         </div>
    <div class="flex-grow-1">
     <div class="fw-bold text-white mb-1"><%# Eval("ItemName") %></div>
     <div class="small text-white-50 mb-2 text-truncate" style="max-width:200px"><%# Eval("ItemDescription") %></div>
  <div class="text-warning fw-bold fs-5">PHP <%# Eval("Price", "{0:N2}") %></div>
     </div>
   <asp:LinkButton ID="btnAddToCart" runat="server" CssClass="btn btn-warning fw-bold text-white rounded-3 px-3 py-2" 
          CommandName="AddToCart" 
    CommandArgument='<%# Eval("ItemID") + "," + Eval("ItemName") + "," + Eval("Price") %>'>
          <i class="bi bi-plus-lg"></i>
 </asp:LinkButton>
 </div>
    </ItemTemplate>
 </asp:Repeater>
   
   <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="unltd-empty">
     <i class="bi bi-inbox unltd-empty__icon"></i>
       <h5 class="unltd-empty__title">No items found</h5>
          <p class="unltd-empty__text">Try selecting a different category or check back later</p>
 </asp:Panel>
     </ContentTemplate>
  </asp:UpdatePanel>
  </div>

 <!-- Floating Cart Button -->
    <a href="GuestCart.aspx" class="cart-badge bg-warning text-white rounded-circle d-flex align-items-center justify-content-center shadow position-fixed" style="bottom:20px;right:20px;width:60px;height:60px;z-index:100;text-decoration:none">
            <i class="bi bi-cart3 fs-3 text-dark"></i>
      <asp:Label ID="lblCartCount" runat="server" CssClass="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" Text="0"></asp:Label>
    </a>

      <!-- Toast Notification -->
        <div id="toastNotification" class="toast-notification">
    <i class="bi bi-check-circle me-2"></i>Added to cart!
        </div>

    <asp:HiddenField ID="hfShowToast" runat="server" Value="0" />
    </form>

    <script src="Scripts/app.js"></script>
    <script>
        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
      if(typeof AppLoader !== 'undefined') AppLoader.hide();
        });
   
        function checkToast() {
  var showToast = document.getElementById('<%= hfShowToast.ClientID %>').value;
            if (showToast === '1') {
       showToastNotification();
       document.getElementById('<%= hfShowToast.ClientID %>').value = '0';
            }
        }
  
    function showToastNotification() {
  var toast = document.getElementById('toastNotification');
       toast.classList.add('show');
    setTimeout(function() {
                toast.classList.remove('show');
      }, 2000);
        }
        
        // Run after page loads and after async postback
        if (typeof Sys !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(function() {
     document.getElementById('loadingOverlay').classList.add('active');
    });
      Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
                document.getElementById('loadingOverlay').classList.remove('active');
     checkToast();
       });
        }
 window.onload = checkToast;
    </script>
</body>
</html>
