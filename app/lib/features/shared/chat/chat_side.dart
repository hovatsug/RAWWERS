/// Which side of a conversation this app is on. The same conversation screen
/// serves both apps: it decides whose messages are "mine", how the others
/// are named, and which routes to read and write through.
enum ChatSide { client, pro }

/// The longest message the server accepts (MAX_CHAT_MESSAGE_LENGTH, 2,000
/// by default). The box stops typing there rather than letting someone write
/// what will be refused; if the server's setting is lowered below this, a
/// longer message is refused with its own message and the draft is kept.
const chatMessageMaxLength = 2000;
