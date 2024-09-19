# hxgit

* A haxelib to interact with the Github API

### Installation

Run: 
```
haxelib git hxgit https://github.com/yophlox/hxgit.git
```

### Usage Example:

```haxe
import hxgit.API;
import hxgit.util.User;

var api = new API();
var username = "yophlox";
var user = api.getUser(username);

if (user != null) {
    trace('User details for $username:');
    trace('Avatar URL: ${user.avatarUrl}');
    trace('Name: ${user.name != null ? user.name : "Not available"}');
    trace('Email: ${user.email != null ? user.email : "Not available"}');
    trace('Followers: ${user.followers}');
    trace('Following: ${user.following}');
    trace('Public Repos: ${user.publicRepos}');
    trace('Public Gists: ${user.publicGists}');
    trace('Created At: ${user.createdAt}');
    trace('Updated At: ${user.updatedAt}');
} else {
    trace('Failed to fetch user data for $username');
}
```

### Credits

* [YoPhlox](https://github.com/yophlox) - haxelib :D
* Github - API
* [GuineaPigUuhh](https://github.com/GuineaPigUuhh/haxe-github) - referenced some code, also inspired me to make this