using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Caching;

namespace FlatFileLoaderUtility.Models.Shared
{
    public static class CacheExtensions
    {
        private static readonly object sync = new object();
        public const int DefaultCacheExpiration = 60;

        /// <summary>
        /// Allows Caching of typed data
        /// </summary>
        /// <example><![CDATA[
        /// var user = HttpRuntime
        ///   .Cache
        ///   .GetOrStore<User>(
        ///      string.Format("User{0}", _userId), 
        ///      () => Repository.GetUser(_userId));
        ///
        /// ]]></example>
        /// <typeparam name="T"></typeparam>
        /// <param name="cache">calling object</param>
        /// <param name="key">Cache key</param>
        /// <param name="generator">Func that returns the object to store in cache</param>
        /// <returns></returns>
        /// <remarks>Uses a default cache expiration period as defined in <see cref="CacheExtensions.DefaultCacheExpiration"/></remarks>
        public static T GetOrStore<T>(this Cache cache, string key, Func<T> generator)
        {
            return cache.GetOrStore(key, (cache[key] == null && generator != null) ? generator() : default(T), DefaultCacheExpiration);
        }

        /// <summary>
        /// Allows Caching of typed data
        /// </summary>
        /// <example><![CDATA[
        /// var user = HttpRuntime
        ///   .Cache
        ///   .GetOrStore<User>(
        ///      string.Format("User{0}", _userId), 
        ///      () => Repository.GetUser(_userId));
        ///
        /// ]]></example>
        /// <typeparam name="T"></typeparam>
        /// <param name="cache">calling object</param>
        /// <param name="key">Cache key</param>
        /// <param name="generator">Func that returns the object to store in cache</param>
        /// <param name="expireInMinutes">Time to expire cache in minutes</param>
        /// <returns></returns>
        public static T GetOrStore<T>(this Cache cache, string key, Func<T> generator, double expireInMinutes)
        {
            return cache.GetOrStore(key, (cache[key] == null && generator != null) ? generator() : default(T), expireInMinutes);
        }

        /// <summary>
        /// Allows Caching of typed data
        /// </summary>
        /// <example><![CDATA[
        /// var user = HttpRuntime
        ///   .Cache
        ///   .GetOrStore<User>(
        ///      string.Format("User{0}", _userId),_userId));
        ///
        /// ]]></example>
        /// <typeparam name="T"></typeparam>
        /// <param name="cache">calling object</param>
        /// <param name="key">Cache key</param>
        /// <param name="obj">Object to store in cache</param>
        /// <returns></returns>
        /// <remarks>Uses a default cache expiration period as defined in <see cref="CacheExtensions.DefaultCacheExpiration"/></remarks>
        public static T GetOrStore<T>(this Cache cache, string key, T obj)
        {
            return cache.GetOrStore(key, obj, DefaultCacheExpiration);
        }

        /// <summary>
        /// Allows Caching of typed data
        /// </summary>
        /// <example><![CDATA[
        /// var user = HttpRuntime
        ///   .Cache
        ///   .GetOrStore<User>(
        ///      string.Format("User{0}", _userId), 
        ///      () => Repository.GetUser(_userId));
        ///
        /// ]]></example>
        /// <typeparam name="T"></typeparam>
        /// <param name="cache">calling object</param>
        /// <param name="key">Cache key</param>
        /// <param name="obj">Object to store in cache</param>
        /// <param name="expireInMinutes">Time to expire cache in minutes</param>
        /// <returns></returns>
        public static T GetOrStore<T>(this Cache cache, string key, T obj, double expireInMinutes)
        {
            var result = cache[key];

            if (result == null)
            {
                lock (sync)
                {
                    if (result == null)
                    {
                        result = obj != null ? obj : default(T);
                        cache.Insert(key, result, null, Cache.NoAbsoluteExpiration, TimeSpan.FromMinutes(expireInMinutes), CacheItemPriority.NotRemovable, null);
                    }
                }
            }

            return (T)result;

        }

    }
}