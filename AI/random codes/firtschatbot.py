


def main():
    while True:
        user_message = input("hello please enter a message:")

        if user_message == "hello":
            print(" hi there, how can I help?")
        elif user_message == "hi":
            print("hello! What do you need help with?")
        elif user_message == "how are you":
            print("I'm just a bot, but I'm doing great! How about you?")
        elif user_message == "help":
            print("sure, I can answer basic questions. Try asking about features.")
        elif user_message == "whats your name":
            print("I'm simple rule based bot")
        elif user_message == "bye":
            print("Goodbye! Have a great day !.")
            break
        else:
            print("did not understant ")



if __name__ == "__main__":
    main()