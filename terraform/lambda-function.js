export const handler = (event) => {
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello World!'),
    };
    return response;
}