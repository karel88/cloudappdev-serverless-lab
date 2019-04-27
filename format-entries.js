const md5 = require('spark-md5');

function main(params) {
    return {
        entries: params.rows.map((row) => {
            return {
                name: row.doc.name,
                email: row.doc.email,
                comment: row.doc.comment,
                createdAt: row.doc.createdAt,
                icon: (row.doc.email ? `https://secure.gravatar.com/avatar/${md5.hash(row.doc.email.trim().toLowerCase())}?s=64` : null)
            }
        })
    };
}
exports.main = main;