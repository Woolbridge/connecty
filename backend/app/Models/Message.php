<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    use HasFactory;

    protected $fillable = [
        'sender_id',
        'receiver_id',
        'message_text',
    ];

    /**
     * Automatically append the sender_nickname to JSON output.
     */
    protected $appends = ['sender_nickname'];

    /**
     * Relationship: The user who sent this message.
     */
    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * Relationship: The user who receives this message.
     */
    public function receiver()
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    /**
     * Accessor to get the sender's nickname or name.
     */
    public function getSenderNicknameAttribute()
    {
        return $this->sender->nickname ?? $this->sender->name ?? 'Unknown';
    }
}
