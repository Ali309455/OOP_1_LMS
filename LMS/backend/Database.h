
#include <QSqlDatabase>
#include <QString>

struct LoginResult {
    bool success;
    QVariantMap user;
    QString message; // optional (very useful for UI)
};
class Database {
public:
    static bool connect();
    static void init(); // create tables

    // CRUD functions
    static bool addUser(QString id,QString name, QString email, QString password, QString membership, QString role,QString status);
    static bool addBook(QString isbn, QString name, QString author,int pages, QString genre, QString section, QString publisher,QString edition, QString language,int publicationYear,int total, int available);
    static bool addTransaction(QString txid, QString userId, QString isbn,QString returnDate, QString status, int fine);
    static bool addReview(QString review_id, QString userId, QString username, QString isbn,QString bookname, int rating, QString comment, QString status);
    static bool addWallet(QString user_id,int balance,int status);
    // READ (Array of Objects)
    static QVariantList getUsers();
    static QVariantList getBooks();
    static QVariantList getTransactions();
    static QVariantList getReviews();
    static QVariantList getWallets();

    //update
    static bool updateUser(QString id, QString name, QString email, QString password, QString membership, QString role,QString status = "");
    static bool updateBook(QString isbn,QString name,QString author,QString genre,QString section,QString publisher,QString edition,QString language,int publicationYear,int total,int available);
    static bool updateTransaction(QString txid, QString status, int fine);
    static bool updateReview(QString reviewId,std::optional<int> rating ,std::optional<QString> comment ,std::optional<QString> status );

    // delete
    static bool deleteUser(QString id);
    static bool deleteBook(QString isbn);
    static bool deleteTransaction(QString txid);
    static bool deleteReview(QString reviewId);
    // login result
    static LoginResult loginUser(QString email, QString password);
    static int getMaxIdNumber(const QString& table, const QString& column, const QString& prefix);
};
