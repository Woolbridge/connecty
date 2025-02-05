<?php 

namespace App\Http\Controllers;

use App\Models\Message;
use App\Events\MessageSent;
use App\Events\TypingEvent;
use App\Events\MessageRead;
use Illuminate\Http\Request;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests; // Add this line

class MessageController extends Controller
{
    use AuthorizesRequests;

    public function getMessages(Request $request, $userId)
    {
        $authId = $request->user()->id;
        $messages = Message::where(function ($q) use ($authId, $userId) {
                $q->where('sender_id', $authId)->where('receiver_id', $userId);
            })
            ->orWhere(function ($q) use ($authId, $userId) {
                $q->where('sender_id', $userId)->where('receiver_id', $authId);
            })
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json($messages);
    }

    public function sendMessage(Request $request)
    {
        $request->validate([
            'receiver_id'  => 'required|exists:users,id',
            'message_text' => 'required',
        ]);

        $message = Message::create([
            'sender_id'   => $request->user()->id,
            'receiver_id' => $request->receiver_id,
            'message_text'=> $request->message_text,
        ]);

        broadcast(new MessageSent($message));

        return response()->json($message, 201);
    }

    /**
     * Mark a message as read and broadcast the read receipt.
     */
    public function markAsRead(Request $request, Message $message)
    {
        // Ensure the authenticated user is the receiver
        
        $message->update(['read_at' => now()]);

        broadcast(new MessageRead($message->id, $request->user()->id, $message->sender_id))->toOthers();

        return response()->json($message);
    }

    /**
     * Broadcast a typing event.
     */
    public function typing(Request $request)
    {
        $request->validate([
            'receiver_id' => 'required|integer',
            'is_typing'   => 'required|boolean',
        ]);

        $senderId   = $request->user()->id;
        $receiverId = $request->receiver_id;
        $isTyping   = $request->is_typing;

        broadcast(new TypingEvent($senderId, $receiverId, $isTyping))->toOthers();

        return response()->json(['status' => 'ok']);
    }
}
