<%@ Page Title="Log In" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="Login.aspx.cs" Inherits="NewByteKnight.Account.Login" %>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="divDynamicContentsPlaceHolder">
    <h2>
        Log In
    </h2>
    <fieldset>
        <table>
            <tr>
                <td>
                    <div>
                        Team Name:</div>
                </td>
                <td>
                    <div>
                        <input id="teamName" runat="server" /></div>
                </td>
                <td>
                    <div>
                        <button id="buttonLogin" runat="server">
                            Log in</button>
                    </div>
                </td>
                <td>
                    <div id="errorMsg" style="color:orangered; font-size:15px; display:none;" runat= "server">
                        Log in failed.
                    </div>
                </td>
            </tr>
        </table>
    </fieldset>
</asp:Content>


                                  