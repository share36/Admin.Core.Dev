using RazorEngine.Compilation.ImpromptuInterface.Dynamic;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeService._Extensions
{
    /// <summary>
    /// 
    /// </summary>
    public static class TypeExtension
    {
        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="type"></param>
        /// <param name="obj"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public static T? GetPropertyValue<T>(this Type type, Object obj, String name)
        {
            var pi = type.GetProperty(name);
            if (pi != null)
            {

                var val = pi.PropertyType.IsGenericType ? pi.GetValue(obj, null) : pi.GetValue(obj);

                if (val != null)
                    return (T)Convert.ChangeType(val, typeof(T));
            }

            return default;
        }
    }
    /// <summary>
    /// 
    /// </summary>
    public static class ICollectionExtension
    {
        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="collection"></param>
        /// <param name="exp"></param>
        /// <param name="val"></param>
        /// <returns></returns>
        public static ICollection<T> AddIf<T>(this ICollection<T> collection, Boolean exp, T val)
        {
            if (exp)
                collection.Add(val);

            return collection;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="collection"></param>
        /// <param name="exp"></param>
        /// <param name="vals"></param>
        /// <returns></returns>
        public static ICollection<T> AddIf<T>(this ICollection<T> collection, Boolean exp, T[] vals)
        {
            if(exp)
                foreach(var v in vals)
                    collection.Add(v);

            return collection;
        }
    }
}
