﻿using RazorEngine.Compilation.ImpromptuInterface.Dynamic;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeService._Extensions
{
    public static class TypeExtension
    {
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
    public static class ICollectionExtension
    {
        public static ICollection<T> AddIf<T>(this ICollection<T> collection, Boolean exp, T val)
        {
            if (exp)
                collection.Add(val);

            return collection;
        }

        public static ICollection<T> AddIf<T>(this ICollection<T> collection, Boolean exp, T[] vals)
        {
            if(exp)
                foreach(var v in vals)
                    collection.Add(v);

            return collection;
        }
    }
}
