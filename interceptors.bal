import ballerina/http;
import ballerina/uuid;

isolated service class RequestInterceptor {
    *http:RequestInterceptor;

    isolated resource function 'default [string... path](
            http:RequestContext ctx,
            http:Request request,
            @http:Header {name: "request-id"} string? requestId)
        returns http:NextService|error? {  
        if requestId is () {
            uuid:Uuid uuid4Record = check uuid:createType4AsRecord();
            request.setHeader("request-id", uuid4Record.toString());
        }
        return ctx.next();
    }
}

isolated service class ResponseErrorInterceptor {
    *http:ResponseErrorInterceptor;

    isolated remote function interceptResponseError(error err) returns http:Response {
        HttpError httpError = <HttpInternalServerError> {
            body: {
                message: "internal server error"
            }
        };
        if err is DatabaseNotFoundError {
            httpError = <HttpNotFoundError>{
               body:  {
                    message: "item not found"
               }
            };
        } else if err is InputValidationError {
            httpError = <HttpBadRequestError>{
               body:  {
                    message: "invalid input"
               }
            };
        } else {
            httpError =  <HttpInternalServerError>{
               body:  {
                    message: "internal server error"
               }
            };
        }
        return constructResponse(httpError);
    }
}

isolated function constructResponse(HttpError httpError) returns http:Response {
    http:Response response = new;
    response.statusCode = httpError.statusCode;
    response.setJsonPayload(httpError.body.toJson());
    return response;
}