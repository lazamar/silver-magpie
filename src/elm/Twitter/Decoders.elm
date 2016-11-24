module Twitter.Decoders exposing (tweetDecoder, userDecoder)

import Twitter.Decoders.TweetDecoder
import Twitter.Decoders.UserDecoder

-- 
--      These functions decode Tweets from the Twitter API
--
tweetDecoder = Twitter.Decoders.TweetDecoder.tweetDecoder
userDecoder = Twitter.Decoders.UserDecoder.userDecoder
