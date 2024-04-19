type DatabaseNotFoundError distinct error;

type InputValidationError distinct error;

type SystemError distinct error;

type HttpError HttpNotFoundError | HttpInternalServerError | HttpBadRequestError;

type HttpNotFoundError record {
    int statusCode = 404;
    record {
        string message;
    } body;
};

type HttpInternalServerError record {
    int statusCode = 500;
    record {
        string message;
    } body;
};

type HttpBadRequestError record {
    int statusCode = 400;
    record {
        string message;
    } body;
};
