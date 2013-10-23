using System;
using System.Web;

namespace NewByteKnight.Common
{
    public class StateHelper
    {
        public static int TeamId
        {
            set
            {
                string teamIdKey = Constant.SessionKey.UserId;
                HttpContext.Current.Session[teamIdKey] = value;
                AddToCookie(value.ToString(), teamIdKey);
            }
            get
            {
                string teamIdKey = Constant.SessionKey.UserId;
                if (HttpContext.Current.Session != null && HttpContext.Current.Session[teamIdKey] != null)
                {
                    return Convert.ToInt32(HttpContext.Current.Session[teamIdKey]);
                }
                HttpCookie formCookie = HttpContext.Current.Request.Cookies[teamIdKey];
                if (formCookie != null)
                {
                    var userId = formCookie.Value;
                    if (!string.IsNullOrWhiteSpace(userId))
                    {
                        return Convert.ToInt32(userId);
                    }
                }
                return -1;

            }
        }


        public static void AddToCookie(string value, string name)
        {
            var cookie = new HttpCookie(name) { Value = value, Expires = DateTime.Now.AddYears(1) };
            HttpContext.Current.Response.Cookies.Add(cookie);
        }
    }
}
