import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import Markdown from 'react-native-markdown-display';
import { Message } from '../types/chat';

interface ChatMessageProps {
  message: Message;
}

function formatTime(date: Date): string {
  return date.toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit',
  });
}

export default function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.sender === 'user';

  return (
    <View style={[styles.wrapper, isUser ? styles.wrapperUser : styles.wrapperBot]}>
      <View style={[styles.bubble, isUser ? styles.bubbleUser : styles.bubbleBot]}>
        {isUser ? (
          <Text style={[styles.content, styles.contentUser]}>
            {message.content}
          </Text>
        ) : (
          <Markdown style={markdownStyles}>
            {message.content}
          </Markdown>
        )}
        <View style={styles.meta}>
          <Text style={[styles.time, isUser ? styles.timeUser : styles.timeBot]}>
            {formatTime(new Date(message.timestamp))}
          </Text>
          {isUser && (
            <Ionicons name="checkmark-done" size={16} color="#34D399" />
          )}
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    paddingHorizontal: 12,
    paddingVertical: 2,
  },
  wrapperUser: {
    alignItems: 'flex-end',
  },
  wrapperBot: {
    alignItems: 'flex-start',
  },
  bubble: {
    maxWidth: '80%',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 12,
  },
  bubbleUser: {
    backgroundColor: '#DCF8C6',
    borderTopRightRadius: 4,
  },
  bubbleBot: {
    backgroundColor: 'white',
    borderTopLeftRadius: 4,
  },
  content: {
    fontSize: 15,
    lineHeight: 20,
  },
  contentUser: {
    color: '#1F2937',
  },
  contentBot: {
    color: '#1F2937',
  },
  meta: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
    gap: 4,
    marginTop: 4,
  },
  time: {
    fontSize: 11,
  },
  timeUser: {
    color: '#6B7280',
  },
  timeBot: {
    color: '#9CA3AF',
  },
});

const markdownStyles = {
  body: {
    fontSize: 15,
    lineHeight: 20,
    color: '#1F2937',
  },
  paragraph: {
    marginTop: 0,
    marginBottom: 4,
  },
  strong: {
    fontWeight: 'bold',
    color: '#111827',
  },
  em: {
    fontStyle: 'italic',
  },
  bullet_list: {
    marginTop: 4,
    marginBottom: 4,
  },
  ordered_list: {
    marginTop: 4,
    marginBottom: 4,
  },
  list_item: {
    marginTop: 2,
    marginBottom: 2,
  },
  bullet_list_icon: {
    fontSize: 15,
    lineHeight: 20,
  },
  heading1: {
    fontSize: 20,
    fontWeight: 'bold',
    marginTop: 8,
    marginBottom: 4,
  },
  heading2: {
    fontSize: 18,
    fontWeight: 'bold',
    marginTop: 6,
    marginBottom: 4,
  },
  heading3: {
    fontSize: 16,
    fontWeight: 'bold',
    marginTop: 4,
    marginBottom: 4,
  },
  code_inline: {
    backgroundColor: '#F3F4F6',
    color: '#EF4444',
    paddingHorizontal: 4,
    paddingVertical: 2,
    borderRadius: 4,
    fontSize: 14,
    fontFamily: 'monospace',
  },
  code_block: {
    backgroundColor: '#F3F4F6',
    padding: 8,
    borderRadius: 4,
    fontSize: 14,
    fontFamily: 'monospace',
  },
  link: {
    color: '#DC2626',
    textDecorationLine: 'underline',
  },
  blockquote: {
    borderLeftWidth: 4,
    borderLeftColor: '#DC2626',
    paddingLeft: 8,
    fontStyle: 'italic',
  },
};
