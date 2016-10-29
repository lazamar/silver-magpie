module Twitter.Decoders exposing (tweetDecoder, userDecoder)

import Twitter.Decoders.TweetDecoder
import Twitter.Decoders.UserDecoder

tweetDecoder = Twitter.Decoders.TweetDecoder.tweetDecoder
userDecoder = Twitter.Decoders.UserDecoder.userDecoder
