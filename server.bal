import ballerina/http;
import ballerina/io;

type Album readonly & record {|
    string title;
    string artist;
|};

table<Album> key(title) albums = table [
    {title: "Blue Train", artist: "John Coltrane"},
    {title: "Sarah Vaughan and Clifford Brown", artist: "Sarah Vaughan"}
];

service http:InterceptableService / on new http:Listener(9090) {

    public function createInterceptors() returns [RequestInterceptor, ResponseErrorInterceptor] {
        // To handle all of the errors in the request path, the `ResponseErrorInterceptor`
        // is added as the last interceptor as it has to be executed last.
        return [new RequestInterceptor(), new ResponseErrorInterceptor()];
    }

    resource function get albums(@http:Header {name: "request-id"} string requestId) returns Album[] {
        return albums.toArray();
    }

    resource function get albums/[string title](@http:Header {name: "request-id"} string requestId) returns Album|error {
        Album|error? album = trap albums.get(title);
        if album == () || album is error {
            io:println("Album not found");
            return error DatabaseNotFoundError("Album not found");
        }
        return album;
    }
}
