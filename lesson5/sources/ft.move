
module lesson5::FT_TOKEN {
    use std::option;
    use sui::coin::{Self};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self};
    use sui::event::emit;
    use std::string
    struct FT_TOKEN has drop { }
    
    const E_NOT_ENOUGH:u64 =0;
    //Event
    struct TransferSuccess has copy, drop {
        value:u64,
        recipient: address   
    }

    fun init(witness: FT_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<FT_TOKEN>(
            witness, 
            9,
            b"NTL",
            b"NT Luong",
            b"NTL Token on sui devnet",
            option::some(url::new_unsafe_from_bytes(b"https://www.ntluongbn62.com")),
            ctx
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, sender);
    }

   // hoàn thiện function để có thể tạo ra 10_000 token cho mỗi lần mint, và mỗi owner của token mới có quyền mint
    public fun mint<FT_TOKEN>(cap:&mut coin::TreasuryCap<FT_TOKEN>,ctx: &mut TxContext) {
         let minted_coin = coin::mint(cap,10_000_000_000_000,ctx);
         transfer::public_transfer(minted_coin, sender);

    }

    // Hoàn thiện function sau để user hoặc ai cũng có quyền tự đốt đi số token đang sở hữu
    public entry fun burn_token(c:Coin<FT_TOKEN>):u64 {
         coin::burn(c)
    }
    
    // Hoàn thiện function để chuyển token từ người này sang người khác.
    public entry fun transfer_token(c:Coin<FT_TOKEN>,recipient: address,ctx:&mut TxContext) {
          let amount = coin::value(&c)
          transfer::public_transfer(c,recipient)
          emit(TransferSuccess {
           value:amount,
           recipient
        });
        // sau đó khởi 1 Event, dùng để tạo 1 sự kiện khi function transfer được thực thi
    }

    // Hoàn thiện function để chia Token Object thành một object khác dùng cho việc transfer
    // gợi ý sử dụng coin:: framework
    public entry fun split_token(balance:&mut Coin<FT_TOKEN>,amount:u64,ctx:&mut TxContext):Coin<FT_TOKEN> {
        let balance = coin::value(&balance);
        assert!(balance >= amount,E_NOT_ENOUGH);
        coin::split(balance,amount,ctx)
    }

    // Viết thêm function để token có thể update thông tin sau
    public entry fun update_name(_treasury: &coin::TreasuryCap<FT_TOKEN>, name:string::String ,metadata: &mut coin::CoinMetadata<FT_TOKEN>) {
            metadata.name = name
            emit(UpdateEvent {
               success:true,
               data:name
             });
    }
    public entry fun update_description(_treasury: &coin::TreasuryCap<FT_TOKEN>, description:string::String ,metadata: &mut coin::CoinMetadata<FT_TOKEN>) {
            metadat.description = description
            emit(UpdateEvent {
            success:true,
            data:description
         });
    }
    public entry fun update_symbol(_treasury: &coin::TreasuryCap<FT_TOKEN>, symbol:string::String ,metadata: &mut coin::CoinMetadata<FT_TOKEN>) {
           metadat.symbol = symbol
           emit(UpdateEvent {
           success:true,
          data:description
     });
    }
    public entry fun update_icon_url(_treasury: &coin::TreasuryCap<FT_TOKEN>, url:string::String ,metadata: &mut coin::CoinMetadata<FT_TOKEN>) {
        metadat.icon_url = option::some(url::new_unsafe(string::to_ascii(url)))
        emit(UpdateEvent {
        success:true,
        data:url})
    }

    // sử dụng struct này để tạo event cho các function update bên trên.
    struct UpdateEvent has copy,drop {
        success: bool,
        data: String
    }

    // Viết các function để get dữ liệu từ token về để hiển thị
    public entry fun get_token_name(metadata:&coin::CoinMetadata<FT_TOKEN>):string::String {
        metadata.name
    }
    public entry fun get_token_description(metadata:&coin::CoinMetadata<FT_TOKEN>):string::String {
        metadata.description
    }
    public entry fun get_token_symbol(metadata:&coin::CoinMetadata<FT_TOKEN>):string::String {
        metadata.symbol
    }
    public entry fun get_token_icon_url(metadata:&coin::CoinMetadata<FT_TOKEN>): option::Option<url::Url> {
        metadata.icon_url
    }
}
