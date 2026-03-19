<%@ Page Title="Menu Management" Language="C#" AutoEventWireup="true" CodeBehind="MenuManagement.aspx.cs" Inherits="UNLTDWingsApp.MenuManagement" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Menu Management - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body class="unltd-admin">
  <form id="form1" runat="server">
      <div class="unltd-container pt-sm-3">
          <!-- Header -->
          <div class="admin-header d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom border-light border-opacity-25 animate-fade-in-down">
              <div class="d-flex align-items-center gap-3">
                  <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn btn-outline-light rounded-circle d-flex align-items-center justify-content-center" style="width:40px;height:40px;">
                      <i class="bi bi-arrow-left"></i>
                  </asp:LinkButton>
                  <h4 class="m-0 fw-bold text-white">Menu Management</h4>
              </div>
              <asp:Button ID="btnShowAdd" runat="server" Text="+ Add Item" CssClass="btn btn-warning fw-bold rounded-pill px-4" OnClick="btnShowAdd_Click" />
          </div>

          <div class="content">
             <asp:Label ID="lblMessage" runat="server" CssClass="toast-notification" Visible="false"></asp:Label>

            <!-- Add/Edit Form Panel -->
             <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="admin-card mb-4 animate-fade-in-up">
                 <div class="admin-section-title d-flex align-items-center gap-2 mb-3">
                      <i class="bi bi-plus-circle"></i>
                     <asp:Label ID="lblFormTitle" runat="server" Text="Add New Menu Item"></asp:Label>
                 </div>
                 <asp:HiddenField ID="hfItemID" runat="server" Value="0" />
              
                <div class="row g-3">
                  <div class="col-12">
                    <label class="form-label text-white-50">Item Name *</label>
                      <asp:TextBox ID="txtItemName" runat="server" CssClass="form-control" placeholder="e.g., Buffalo Wings 6pcs" MaxLength="100"></asp:TextBox>
                  </div>
                    <div class="col-12">
                      <label class="form-label text-white-50">Description</label>
                  <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" placeholder="Brief description of the item" MaxLength="255" TextMode="MultiLine" Rows="2"></asp:TextBox>
                            </div>
                   <div class="col-6">
                 <label class="form-label text-white-50">Category *</label>
                             <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select">
                          <asp:ListItem Text="Unlimited" Value="Unlimited"></asp:ListItem>
                         <asp:ListItem Text="Wings" Value="Wings"></asp:ListItem>
                        <asp:ListItem Text="Rice Meals" Value="Rice Meals"></asp:ListItem>
                     <asp:ListItem Text="Pasta" Value="Pasta"></asp:ListItem>
                      <asp:ListItem Text="Combos" Value="Combos"></asp:ListItem>
                             <asp:ListItem Text="Fries" Value="Fries"></asp:ListItem>
                    <asp:ListItem Text="Drinks" Value="Drinks"></asp:ListItem>
                          <asp:ListItem Text="Add-ons" Value="Add-ons"></asp:ListItem>
                           </asp:DropDownList>
                     </div>
                      <div class="col-6">
                           <label class="form-label text-white-50">Price (PHP) *</label>
                     <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control" placeholder="0.00" TextMode="Number" step="0.01" min="0"></asp:TextBox>
                     </div>
                <div class="col-12">
                       <div class="form-check form-switch">
                           <asp:CheckBox ID="chkAvailable" runat="server" CssClass="form-check-input" Checked="true" />
                        <label class="form-check-label text-white" for="chkAvailable">Available for ordering</label>
                       </div>
                 </div>
                    <div class="col-12 d-flex gap-2 mt-3">
                         <asp:Button ID="btnSave" runat="server" Text="Save Item" CssClass="btn btn-warning fw-bold px-4 rounded-pill" OnClick="btnSave_Click" />
                  <asp:Button ID="btnCancelForm" runat="server" Text="Cancel" CssClass="btn btn-outline-light px-4 rounded-pill" OnClick="btnCancelForm_Click" CausesValidation="false" />
                     </div>
                </div>
             </asp:Panel>

            <!-- Menu Items List -->
            <div class="mb-5 animate-fade-in-up stagger-1">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="admin-section-title m-0">
                       <i class="bi bi-menu-button-wide me-2"></i>
                        Menu Items (<asp:Label ID="lblItemCount" runat="server" Text="0"></asp:Label>)
                    </h5>
                </div>

                <div class="d-flex gap-2 flex-wrap mb-4">
                     <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="btn btn-sm btn-outline-dark rounded-pill active" OnClick="btnFilter_Click" CommandArgument="All">All</asp:LinkButton>
                     <asp:LinkButton ID="btnFilterUnlimited" runat="server" CssClass="btn btn-sm btn-outline-dark rounded-pill" OnClick="btnFilter_Click" CommandArgument="Unlimited">Unlimited</asp:LinkButton>
                     <asp:LinkButton ID="btnFilterWings" runat="server" CssClass="btn btn-sm btn-outline-dark rounded-pill" OnClick="btnFilter_Click" CommandArgument="Wings">Wings</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterRice" runat="server" CssClass="btn btn-sm btn-outline-dark rounded-pill" OnClick="btnFilter_Click" CommandArgument="Rice Meals">Rice Meals</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterPasta" runat="server" CssClass="btn btn-sm btn-outline-dark rounded-pill" OnClick="btnFilter_Click" CommandArgument="Pasta">Pasta</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterCombos" runat="server" CssClass="btn btn-sm btn-outline-dark rounded-pill" OnClick="btnFilter_Click" CommandArgument="Combos">Combos</asp:LinkButton>
                     <asp:LinkButton ID="btnFilterFries" runat="server" CssClass="btn btn-sm btn-outline-dark rounded-pill" OnClick="btnFilter_Click" CommandArgument="Fries">Fries</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterDrinks" runat="server" CssClass="btn btn-sm btn-outline-dark rounded-pill" OnClick="btnFilter_Click" CommandArgument="Drinks">Drinks</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterAddons" runat="server" CssClass="btn btn-sm btn-outline-dark rounded-pill" OnClick="btnFilter_Click" CommandArgument="Add-ons">Add-ons</asp:LinkButton>
                </div>

                 <asp:Repeater ID="rptMenuItems" runat="server" OnItemCommand="rptMenuItems_ItemCommand">
                     <ItemTemplate>
                         <div class="admin-card mb-2 card-hover p-3 d-flex align-items-center gap-3">
                             <div class="admin-icon-box medium bg-white text-dark">
                                 <i class="bi bi-egg-fried"></i>
                             </div>
                             
                             <div class="flex-grow-1">
                                 <div class="fw-bold text-white"><%# Eval("ItemName") %></div>
                                 <div class="small text-white-50"><%# Eval("ItemCategory") %></div>
                             </div>
                             
                             <div class="text-warning fw-bold">?<%# Eval("Price", "{0:0.00}") %></div>
                             
                             <span class='badge rounded-pill <%# Convert.ToBoolean(Eval("IsAvailable")) ? "bg-success" : "bg-danger" %>'>
                                  <%# Convert.ToBoolean(Eval("IsAvailable")) ? "Available" : "Unavailable" %>
                             </span>
                             
                             <div class="d-flex gap-2 ms-3">
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-light" CommandName="Edit" CommandArgument='<%# Eval("ItemID") %>'>
                                    <i class="bi bi-pencil"></i>
                               </asp:LinkButton>
                                 <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-sm btn-outline-danger border-danger" CommandName="Delete" CommandArgument='<%# Eval("ItemID") %>' OnClientClick="return confirm('Are you sure you want to delete this item?');">
                                   <i class="bi bi-trash"></i>
                                  </asp:LinkButton>
                              </div>
                         </div>
                     </ItemTemplate>
                  </asp:Repeater>

                  <asp:Panel ID="pnlNoItems" runat="server" Visible="false">
                      <div class="text-center py-5 text-muted">
                          <i class="bi bi-inbox d-block display-4 mb-3 opacity-25"></i>
                          <p>No menu items found</p>
                       </div>
                  </asp:Panel>
              </div>
          </div>
      </div>
    </form>
</body>
</html>
