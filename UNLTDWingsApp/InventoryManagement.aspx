<%@ Page Title="Inventory Management" Language="C#" AutoEventWireup="true" CodeBehind="InventoryManagement.aspx.cs" Inherits="UNLTDWingsApp.InventoryManagement" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Inventory Management - UNLTD Wings</title>
   <link href="Content/bootstrap.min.css" rel="stylesheet" />
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
        .btn-add-new {
    background: #28a745;
     color: white;
  border: none;
      padding: 8px 15px;
            border-radius: 20px;
       font-size: 13px;
     font-weight: 600;
     }
        .content { padding: 20px; }
        .stats-row {
   display: grid;
     grid-template-columns: repeat(3, 1fr);
  gap: 10px;
            margin-bottom: 20px;
        }
.stat-box {
    background: white;
         border-radius: 12px;
   padding: 15px;
     text-align: center;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
     }
 .stat-value { font-size: 24px; font-weight: 700; color: #5E2D10; }
.stat-label { font-size: 11px; color: #888; }
  .stat-box.warning { border-left: 4px solid #ffc107; }
        .stat-box.danger { border-left: 4px solid #dc3545; }
        .section {
    background: white;
   border-radius: 15px;
            padding: 20px;
  margin-bottom: 15px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
   }
        .section-title {
     color: #5E2D10;
    font-size: 16px;
        font-weight: 700;
         margin-bottom: 15px;
         display: flex;
      align-items: center;
      gap: 8px;
  }
        .form-label {
      color: #5E2D10;
 font-weight: 600;
           font-size: 13px;
 margin-bottom: 5px;
}
      .form-control, .form-select {
border: 2px solid #E8D5B5;
       border-radius: 10px;
   padding: 10px 15px;
  font-size: 14px;
        }
        .form-control:focus, .form-select:focus {
  border-color: #5E2D10;
       box-shadow: 0 0 0 2px rgba(94, 45, 16, 0.1);
      }
      .btn-save {
  background: #5E2D10;
  color: white;
    border: none;
        border-radius: 10px;
     padding: 12px 25px;
     font-weight: 600;
    }
        .btn-save:hover { background: #4a230c; color: white; }
  .btn-cancel {
        background: #6c757d;
   color: white;
   border: none;
  border-radius: 10px;
    padding: 12px 25px;
      font-weight: 600;
    }
        .inventory-row {
      display: flex;
    align-items: center;
    padding: 12px 0;
     border-bottom: 1px solid #F0E8E0;
            gap: 15px;
      }
        .inventory-row:last-child { border-bottom: none; }
   .inv-icon {
      width: 45px;
   height: 45px;
     background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
     border-radius: 10px;
         display: flex;
            justify-content: center;
       align-items: center;
            flex-shrink: 0;
      }
        .inv-icon.low { background: linear-gradient(135deg, #dc3545 0%, #fd7e14 100%); }
        .inv-icon i { color: white; font-size: 1.2rem; }
   .inv-details { flex: 1; }
        .inv-name { font-weight: 600; font-size: 14px; color: #2C2C2C; }
        .inv-unit { font-size: 12px; color: #888; }
 .inv-stock {
          text-align: right;
        }
     .stock-value { font-weight: 700; font-size: 18px; color: #5E2D10; }
        .stock-value.low { color: #dc3545; }
    .reorder-level { font-size: 11px; color: #888; }
        .inv-actions { display: flex; gap: 8px; }
        .btn-restock {
        background: #28a745;
       color: white;
border: none;
       padding: 6px 12px;
       border-radius: 6px;
            font-size: 12px;
  }
        .btn-edit {
         background: #007bff;
   color: white;
   border: none;
    padding: 6px 12px;
        border-radius: 6px;
  font-size: 12px;
        }
        .message {
            padding: 12px;
border-radius: 10px;
  text-align: center;
    font-weight: 600;
   margin-bottom: 15px;
        }
        .message.success { background: #d4edda; color: #155724; }
        .message.error { background: #f8d7da; color: #721c24; }
 /* Restock Modal */
        .restock-panel {
     background: #FFF3E0;
            border: 2px solid #FFB74D;
  border-radius: 12px;
  padding: 15px;
         margin-bottom: 15px;
   }
 .restock-title {
     color: #E65100;
     font-weight: 700;
     margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
<asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="back-btn">
       <i class="bi bi-arrow-left"></i>
 </asp:LinkButton>
    <span class="page-title">Inventory Management</span>
         <asp:Button ID="btnShowAdd" runat="server" Text="+ Add Item" CssClass="btn-add-new" OnClick="btnShowAdd_Click" />
     </div>

     <div class="content">
        <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>

   <!-- Stats -->
    <div class="stats-row">
     <div class="stat-box">
     <div class="stat-value"><asp:Label ID="lblTotalItems" runat="server" Text="0"></asp:Label></div>
  <div class="stat-label">Total Items</div>
       </div>
 <div class="stat-box warning">
  <div class="stat-value"><asp:Label ID="lblLowStock" runat="server" Text="0"></asp:Label></div>
   <div class="stat-label">Low Stock</div>
 </div>
         <div class="stat-box danger">
     <div class="stat-value"><asp:Label ID="lblOutOfStock" runat="server" Text="0"></asp:Label></div>
      <div class="stat-label">Out of Stock</div>
   </div>
  </div>

            <!-- Restock Panel -->
   <asp:Panel ID="pnlRestock" runat="server" Visible="false" CssClass="restock-panel">
     <div class="restock-title">
        <i class="bi bi-box-seam me-2"></i>Restock: <asp:Label ID="lblRestockItem" runat="server"></asp:Label>
   </div>
     <asp:HiddenField ID="hfRestockID" runat="server" />
       <div class="row g-2 align-items-end">
        <div class="col">
 <label class="form-label">Add Quantity</label>
      <asp:TextBox ID="txtRestockQty" runat="server" CssClass="form-control" TextMode="Number" min="1" placeholder="Enter quantity to add"></asp:TextBox>
    </div>
       <div class="col-auto">
       <asp:Button ID="btnConfirmRestock" runat="server" Text="Add Stock" CssClass="btn-save" OnClick="btnConfirmRestock_Click" />
 </div>
 <div class="col-auto">
          <asp:Button ID="btnCancelRestock" runat="server" Text="Cancel" CssClass="btn-cancel" OnClick="btnCancelRestock_Click" CausesValidation="false" />
           </div>
         </div>
    </asp:Panel>

     <!-- Add/Edit Form -->
  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="section">
<div class="section-title">
          <i class="bi bi-plus-circle"></i>
        <asp:Label ID="lblFormTitle" runat="server" Text="Add New Inventory Item"></asp:Label>
     </div>
     <asp:HiddenField ID="hfItemID" runat="server" Value="0" />
         
        <div class="row g-3">
        <div class="col-12">
   <label class="form-label">Ingredient Name *</label>
             <asp:TextBox ID="txtIngredientName" runat="server" CssClass="form-control" placeholder="e.g., Chicken Wings" MaxLength="100"></asp:TextBox>
                    </div>
   <div class="col-4">
        <label class="form-label">Stock Level *</label>
        <asp:TextBox ID="txtStockLevel" runat="server" CssClass="form-control" TextMode="Number" step="0.01" min="0" placeholder="0"></asp:TextBox>
        </div>
     <div class="col-4">
        <label class="form-label">Unit *</label>
          <asp:DropDownList ID="ddlUnit" runat="server" CssClass="form-select">
     <asp:ListItem Text="pcs" Value="pcs"></asp:ListItem>
    <asp:ListItem Text="kg" Value="kg"></asp:ListItem>
        <asp:ListItem Text="liters" Value="liters"></asp:ListItem>
      <asp:ListItem Text="packs" Value="packs"></asp:ListItem>
       </asp:DropDownList>
       </div>
        <div class="col-4">
   <label class="form-label">Reorder Level *</label>
        <asp:TextBox ID="txtReorderLevel" runat="server" CssClass="form-control" TextMode="Number" step="0.01" min="0" placeholder="10"></asp:TextBox>
     </div>
    <div class="col-12 d-flex gap-2 mt-3">
       <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn-save" OnClick="btnSave_Click" />
     <asp:Button ID="btnCancelForm" runat="server" Text="Cancel" CssClass="btn-cancel" OnClick="btnCancelForm_Click" CausesValidation="false" />
          </div>
                </div>
     </asp:Panel>

            <!-- Inventory List -->
     <div class="section">
  <div class="section-title">
     <i class="bi bi-box-seam"></i>
  Inventory Items
    </div>

    <asp:Repeater ID="rptInventory" runat="server" OnItemCommand="rptInventory_ItemCommand">
      <ItemTemplate>
         <div class="inventory-row">
   <div class='<%# Convert.ToDecimal(Eval("StockLevel")) <= Convert.ToDecimal(Eval("ReorderLevel")) ? "inv-icon low" : "inv-icon" %>'>
      <i class="bi bi-box"></i>
         </div>
  <div class="inv-details">
         <div class="inv-name"><%# Eval("IngredientName") %></div>
      <div class="inv-unit">Unit: <%# Eval("Unit") %></div>
    </div>
        <div class="inv-stock">
       <div class='<%# Convert.ToDecimal(Eval("StockLevel")) <= Convert.ToDecimal(Eval("ReorderLevel")) ? "stock-value low" : "stock-value" %>'>
          <%# Eval("StockLevel", "{0:0.##}") %> <%# Eval("Unit") %>
    </div>
     <div class="reorder-level">Reorder at: <%# Eval("ReorderLevel", "{0:0.##}") %></div>
              </div>
        <div class="inv-actions">
   <asp:LinkButton ID="btnRestock" runat="server" CssClass="btn-restock" CommandName="Restock" CommandArgument='<%# Eval("InventoryID") + "|" + Eval("IngredientName") %>'>
    <i class="bi bi-plus-lg"></i> Restock
      </asp:LinkButton>
 <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn-edit" CommandName="Edit" CommandArgument='<%# Eval("InventoryID") %>'>
      <i class="bi bi-pencil"></i>
      </asp:LinkButton>
            </div>
       </div>
        </ItemTemplate>
   </asp:Repeater>

  <asp:Panel ID="pnlNoItems" runat="server" Visible="false">
            <div class="text-center py-4 text-muted">
  <i class="bi bi-inbox d-block" style="font-size: 3rem;"></i>
          <p>No inventory items found</p>
      </div>
 </asp:Panel>
    </div>
        </div>
    </form>
</body>
</html>
