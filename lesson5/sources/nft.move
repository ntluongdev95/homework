module lesson5::discount_coupon {
    use sui::transfer::{Self,public_transfer,transfer};
    use sui::coin::{Self,SUI};
    use sui::clock::{Self, Clock};
    use sui::tx_context::{Self, TxContext,sender};

    const ECouponExpired:u8 =0;
    const EWrongOwner:u8 =1;
    const EBalance:u8 =2;
    const EWrongRecipient:u8 =3;

    struct DiscountCoupon has key {
        id: UID,
        owner: address,
        discount: u8,
        expiration: u64,
        
    };

    /// Lấy thông tin của người sở hữu
    public fun owner(coupon: &DiscountCoupon): address {
        coupon.owner
    }

    /// Lấy thông tin discount của coupon
    public fun discount(coupon: &DiscountCoupon): u8 {
        coupon.discount
    }

    // Hoàn thiện function để mint 1 coupon và transfer coupon này cho một người nhận recipient
    public entry fun mint_and_topup(
        coin: coin::Coin<SUI>,
        discount: u8,
        expiration: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let balance = coin::value(&coin);
        assert!(balance > 0 , EBalance)
        let coupon = DiscountCoupon{
            id:object::new(ctx);
            owner:tx_context::sender(ctx);
            discount;
            expiration
        }
        transfer::transfer(coupon,recipient);
        transfer::public_transfer(coin,recipient);
    }

    // hoàn thiện function để có thể transfer coupon cho 1 người khác
    public entry fun transfer_coupon(coupon: DiscountCoupon, recipient: address) {
        assert!(coupon.owner == sender,EWrongOwner);
        assert!(recipient != sender,EWrongRecipient);
         transfer::transfer(coupon,recipient)
    }

    // Hoàn thiện function đê huỷ, xoá đi coupon.
    public fun burn(nft: DiscountCoupon): bool {
        let DiscountCoupon {id,owner:_,discount:_,expiration:_} = nft;
        object::delete(id);
        true
    }
    // Hoàn thiện function để người dùng sử dụng, sau đó sẽ xoá đi cái coupon
    public entry fun scan(nft: DiscountCoupon):bool {
        // ....check information
        assert!(clock::timestamp_ms(&Clock) < nft.expiration,ECouponExpired );
        assert!(nft.owner == sender,EWrongOwner)
        burn(nft);
    }
}
