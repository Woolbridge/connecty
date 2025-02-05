<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageRead implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $messageId;
    public $readerId;
    public $senderId;

    public function __construct($messageId, $readerId, $senderId)
    {
        $this->messageId = $messageId;
        $this->readerId = $readerId;
        $this->senderId = $senderId;
    }

    public function broadcastOn()
    {
        // Broadcast on the sender's private channel so they can update the read status.
        return new PrivateChannel('chat.' . $this->senderId);
    }

    public function broadcastAs()
    {
        return 'MessageRead';
    }

    public function broadcastWith()
    {
        return [
            'message_id' => $this->messageId,
            'reader_id'  => $this->readerId,
        ];
    }
}
