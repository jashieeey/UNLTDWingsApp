<%@ Page Title="Order Details" Language="C#" AutoEventWireup="true" CodeBehind="OrderDetails.aspx.cs" Inherits="UNLTDWingsApp.OrderDetails" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
 <meta charset="utf-8" />
 <meta name="viewport" content="width=device-width, initial-scale=1.0" />
 <title>Order Details - UNLTD Wings</title>
 <link href="Content/bootstrap.min.css" rel="stylesheet" />
 <link href="Content/app-styles.css" rel="stylesheet" />
 <style>
 body{ background:#F5F0EB; font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif; }
 .wrap{ max-width:900px; margin:20px auto; padding:020px; }
 .card{ background:#fff; border-radius:12px; box-shadow:02px8px rgba(0,0,0,0.08); padding:18px; margin-bottom:12px; }
 .title{ font-size:22px; font-weight:800; color:#5E2D10; margin-bottom:10px; }
 .kv{ display:flex; gap:10px; margin-bottom:6px; }
 .k{ width:160px; color:#666; font-weight:700; }
 .v{ flex:1; color:#222; }
 table{ width:100%; border-collapse:collapse; }
 th{ text-align:left; background:#5E2D10; color:#fff; padding:10px; }
 td{ padding:10px; border-bottom:1px solid #f0e8e0; }
 .total{ text-align:right; font-size:18px; font-weight:900; color:#C4773B; padding-top:10px; }
 </style>
</head>
<body>
<form id="form1" runat="server">
 <div class="wrap">
 <div class="card">
 <div class="title">Order #<asp:Label ID="lblOrderId" runat="server" /></div>

 <asp:Panel ID="pnlNotFound" runat="server" Visible="false" Style="color:#b00020; font-weight:700;">
 Order not found.
 </asp:Panel>

 <asp:Panel ID="pnlDetails" runat="server" Visible="false">
 <div class="kv"><div class="k">Customer</div><div class="v"><asp:Label ID="lblCustomer" runat="server" /></div></div>
 <div class="kv"><div class="k">Type</div><div class="v"><asp:Label ID="lblType" runat="server" /></div></div>
 <div class="kv"><div class="k">Table</div><div class="v"><asp:Label ID="lblTable" runat="server" /></div></div>
 <div class="kv"><div class="k">Address</div><div class="v"><asp:Label ID="lblAddress" runat="server" /></div></div>
 <div class="kv"><div class="k">Contact</div><div class="v"><asp:Label ID="lblContact" runat="server" /></div></div>
 <div class="kv"><div class="k">Payment</div><div class="v"><asp:Label ID="lblPayment" runat="server" /></div></div>
 <div class="kv"><div class="k">Reference #</div><div class="v"><asp:Label ID="lblRef" runat="server" /></div></div>
 <div class="kv"><div class="k">Status</div><div class="v"><asp:Label ID="lblStatus" runat="server" /></div></div>
 <div class="kv"><div class="k">Order Date</div><div class="v"><asp:Label ID="lblDate" runat="server" /></div></div>
 </asp:Panel>
 </div>

 <asp:Panel ID="pnlItems" runat="server" Visible="false" CssClass="card">
 <div class="title" style="font-size:18px;">Items</div>
 <asp:GridView ID="gvItems" runat="server" AutoGenerateColumns="false" CssClass="table" GridLines="None">
 <Columns>
 <asp:BoundField DataField="ItemName" HeaderText="Item" />
 <asp:BoundField DataField="Quantity" HeaderText="Qty" />
 <asp:BoundField DataField="Subtotal" HeaderText="Subtotal" DataFormatString="{0:N2}" />
 </Columns>
 </asp:GridView>
 <div class="total">Total: PHP <asp:Label ID="lblTotal" runat="server" /></div>
 </asp:Panel>
 </div>
</form>
</body>
</html>
