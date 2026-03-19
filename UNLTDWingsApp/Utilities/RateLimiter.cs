using System;
using System.Collections.Generic;
using System.Web;

namespace UNLTDWingsApp.Utilities
{
    /// <summary>
    /// Rate Limiter Utility - Prevents spam and abuse of critical operations
    /// Thread-safe implementation using in-memory dictionary with timestamp tracking
    /// </summary>
  public static class RateLimiter
    {
        /// <summary>
        /// Entry for tracking rate limit attempts
   /// </summary>
        private class RateLimitEntry
   {
public DateTime LastAttempt { get; set; }
        public int AttemptCount { get; set; }
        }

        // Static dictionary to track rate limit entries per session
        private static Dictionary<string, RateLimitEntry> _limitDict = new Dictionary<string, RateLimitEntry>();
     private static readonly object _lockObject = new object();

 /// <summary>
     /// Check if order submission is allowed (1 per 5 seconds per session)
   /// </summary>
        public static bool CanSubmitOrder(string sessionId)
  {
            return CheckLimit(sessionId, "order", 5);
 }

 /// <summary>
        /// Check if GCash reference submission is allowed (1 per 10 seconds per session)
        /// </summary>
        public static bool CanSubmitGCashReference(string sessionId)
        {
  return CheckLimit(sessionId, "gcash", 10);
        }

        /// <summary>
        /// Check if add-to-cart operation is allowed (5 per 10 seconds per session)
        /// </summary>
      public static bool CanAddToCart(string sessionId)
        {
   return CheckLimitWithCount(sessionId, "addtocart", 10, 5);
        }

        /// <summary>
   /// Check if table login is allowed (3 attempts per 30 minutes)
 /// </summary>
        public static bool CanLoginTable(string tableIdentifier)
        {
            return CheckLimitWithCount(tableIdentifier, "tablelogin", 1800, 3);
        }

        /// <summary>
        /// Core rate limit check - one attempt per time window
      /// </summary>
        /// <param name="key">Unique identifier (session ID, table number, etc.)</param>
        /// <param name="operation">Type of operation (order, gcash, etc.)</param>
 /// <param name="secondsDelay">Minimum seconds between attempts</param>
        /// <returns>True if allowed, false if rate limited</returns>
        private static bool CheckLimit(string key, string operation, int secondsDelay)
        {
          lock (_lockObject)
     {
  string fullKey = $"{key}_{operation}";

              // Create entry if doesn't exist
      if (!_limitDict.ContainsKey(fullKey))
                {
       _limitDict[fullKey] = new RateLimitEntry
          {
     LastAttempt = DateTime.Now,
        AttemptCount = 1
   };
    return true;
   }

                var entry = _limitDict[fullKey];
     TimeSpan elapsed = DateTime.Now - entry.LastAttempt;

       // Check if enough time has passed
            if (elapsed.TotalSeconds >= secondsDelay)
                {
        entry.LastAttempt = DateTime.Now;
   entry.AttemptCount = 1;
        return true;
             }

          // Rate limit exceeded
 entry.AttemptCount++;
      return false;
            }
     }

        /// <summary>
        /// Rate limit check with count - allows multiple attempts within time window
        /// </summary>
        /// <param name="key">Unique identifier</param>
        /// <param name="operation">Type of operation</param>
      /// <param name="timeWindowSeconds">Time window in seconds</param>
      /// <param name="maxAttempts">Maximum attempts allowed in time window</param>
        /// <returns>True if allowed, false if rate limited</returns>
        private static bool CheckLimitWithCount(string key, string operation, int timeWindowSeconds, int maxAttempts)
        {
   lock (_lockObject)
    {
             string fullKey = $"{key}_{operation}";

           // Create entry if doesn't exist
  if (!_limitDict.ContainsKey(fullKey))
 {
        _limitDict[fullKey] = new RateLimitEntry
          {
            LastAttempt = DateTime.Now,
            AttemptCount = 1
          };
          return true;
      }

      var entry = _limitDict[fullKey];
    TimeSpan elapsed = DateTime.Now - entry.LastAttempt;

           // Reset if window has passed
           if (elapsed.TotalSeconds >= timeWindowSeconds)
        {
        entry.LastAttempt = DateTime.Now;
    entry.AttemptCount = 1;
              return true;
              }

      // Check if within attempt limit
         if (entry.AttemptCount < maxAttempts)
    {
   entry.AttemptCount++;
        return true;
 }

   // Rate limit exceeded
   return false;
  }
        }

        /// <summary>
        /// Reset rate limit for a specific key/operation (use with caution)
   /// </summary>
        public static void ResetLimit(string key, string operation)
        {
    lock (_lockObject)
            {
     string fullKey = $"{key}_{operation}";
   if (_limitDict.ContainsKey(fullKey))
      {
           _limitDict.Remove(fullKey);
  }
         }
        }

        /// <summary>
        /// Clear all rate limits (typically done on app restart)
     /// </summary>
  public static void ClearAll()
     {
            lock (_lockObject)
        {
         _limitDict.Clear();
    }
        }

        /// <summary>
        /// Get time remaining until next allowed attempt
        /// </summary>
  public static TimeSpan? GetTimeUntilNextAllowed(string key, string operation, int secondsDelay)
        {
        lock (_lockObject)
      {
     string fullKey = $"{key}_{operation}";

                if (!_limitDict.ContainsKey(fullKey))
      {
      return null;
     }

                var entry = _limitDict[fullKey];
    TimeSpan elapsed = DateTime.Now - entry.LastAttempt;
    int waitTime = secondsDelay - (int)Math.Ceiling(elapsed.TotalSeconds);

     if (waitTime > 0)
            {
     return TimeSpan.FromSeconds(waitTime);
      }

      return null;
 }
        }
    }
}
