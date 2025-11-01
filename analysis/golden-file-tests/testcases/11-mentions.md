# Mentions Extension Test

## Basic Mentions

Hello @username!

Thanks @alice and @bob for your help.

## Mentions with Hyphens and Underscores

@user-name is valid
@user_name is also valid
@user-name-123 works too

## Multiple Mentions

@alice, @bob, and @charlie are working on this.

Mentioned: @user1 @user2 @user3

## Mentions in Context

**Bold with @username mention**

*Italic with @username mention*

`Code with @username (should not render)`

> Blockquote with @username mention

- List item with @username
- Another @mention

## Mentions in Links

See [@username's profile](https://github.com/username)

## Edge Cases

Email is not a mention: user@example.com

@123numbers (numeric username)

@ (mention without username)

@@double (double at sign)

@user. (mention with punctuation)

@user, @user; @user: (mentions with various punctuation)

## Real World GitHub-Style Mentions

Thanks @octocat for the review!

/cc @team-lead @reviewer

Fixes #123 (issue reference, not mention)
