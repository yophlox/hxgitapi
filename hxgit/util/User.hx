package hxgit.util;

class User {
    public var login(default, null):String;
    public var id(default, null):Int;
    public var avatarUrl(default, null):String;
    public var htmlUrl(default, null):String;
    public var name(default, null):Null<String>;
    public var email(default, null):Null<String>;
    public var contributions(default, null):Null<Int>;
    public var followers(default, null):Int;
    public var following(default, null):Int;
    public var publicRepos(default, null):Int;
    public var publicGists(default, null):Int;
    public var createdAt(default, null):String;
    public var updatedAt(default, null):String;

    public function new(data:Dynamic) {
        login = data.login != null ? data.login : "Unknown";
        id = data.id != null ? data.id : -1;
        avatarUrl = data.avatar_url != null ? data.avatar_url : "";
        htmlUrl = data.html_url != null ? data.html_url : "";
        name = data.name;
        email = data.email;
        contributions = data.contributions;
        followers = data.followers != null ? data.followers : 0;
        following = data.following != null ? data.following : 0;
        publicRepos = data.public_repos != null ? data.public_repos : 0;
        publicGists = data.public_gists != null ? data.public_gists : 0;
        createdAt = data.created_at != null ? data.created_at : "";
        updatedAt = data.updated_at != null ? data.updated_at : "";
    }

    public static function fromContributor(data:Dynamic):User {
        return new User(data);
    }

    public static function fromCommit(data:Dynamic):User {
        var userData = data.author != null ? data.author : (data.committer != null ? data.committer : {});
        return new User(userData);
    }

    public function toString():String {
        return 'User: $login (ID: $id)${contributions != null ? ", Contributions: " + contributions : ""}';
    }
}