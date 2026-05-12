import app from "./app.js";
import http from 'http';

const server = http.createServer(app);

const PORT = process.env.PORT || 3000;

server.listen(PORT, ()=> {
    console.log(`
        ==========================================
            Instgram Clone Server Running
            http://localhost:${PORT}
            Environment: ${process.env.NODE_ENV || "development"}
        ==========================================
        `);
});

process.on('SIGTERM', ()=> {
    console.log("SIGTERM received, shutting down gracefully ...");
    server.close(()=> {
        console.log('HTTP server closed');
        process.exit(0);
    })
})

process.on('SIGINT', ()=> {
    console.log('\nSIGINT received, shutting down gracefully ...');
    server.close(()=> {
        process.exit(0);
    })
})

export default server;