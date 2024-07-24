# Risk Model

RetroMeet is a dating app that focuses on information about users to help them find other users compatible with themselves. This means that RetroMeet can contain sensitive user information and while some users may not mind that information to be public, other users might be at risk for work reasons, or even for law in the place where they live.

For that reason, every functionality of RetroMeet should keep a few points in mind to mitigate this risk as much as possible.

## Different access levels

When possible, give users the option to only information to selected users, such as all users, users they messaged, liked, or matched. When this is not possible, try to make as clear as possible to users what is public (at least in the context of RetroMeet) so they can make decisions by themselves.

## Rate limit access to other profiles

Bad actors might try to scrape public information from RetroMeet, this is not unheard of in other dating apps. RetroMeet should rate limit access to other profiles to reduce the chance that this data gets scraped by bad actors.

## E2E encryption

This applies mostly to messaging, but RetroMeet should use E2E encryption for messaging to allow for more security when exchanging messages with other users. This is not present in the first version of RetroMeet but the idea is to implement some time soon.
