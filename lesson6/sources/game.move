// hoàn thiện code để module có thể publish được
module lesson6::hero_game {
    use sui::object::{UID,Self,ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext,sender};
    use std::string::{String};
    use std::option::{Option,Self};
    //ERROR
    const ErrorHP:u8 =0;
    const ENotEnough:u8 =1;
    const MonterWin:u8 =2;
    // Điền thêm các ability phù hợp cho các object
    struct Hero has key,store{
        id: UID,
        name: String,
        hp: u64,
        experience: u64,
        armor:Option<Armor>,
        sword:Option<Sword>,
        game_id:ID,

    };
    
    struct GameAdmin has key{
        id:UID,
        game_id:ID,
        monsters:u64,
    };
    // Điền thêm các ability phù hợp cho các object
    struct Sword has key,store {
        id: UID,
        attack: u64,
        strenght: u64,
        game_id:ID,
    };

    // Điền thêm các ability phù hợp cho các object
    struct Armor has key,store {
        id: UID,
        defense: u64,
        game_id:ID,
    };

    // Điền thêm các ability phù hợp cho các object
    struct Monter has key,store {
        id: UID,
        hp: u64,
        strenght: u64,
        game_id:ID,
    };

    struct GameInfo has key {
        id: UID,
        admin: address
    };

    // hoàn thiện function để khởi tạo 1 game mới
    fun init(ctx: &mut TxContext) {
        let id =object::new(ctx);
        let game_id:object::uid_to_inner(&id);
        let game_info = GameInfo{
            id,
            admin:tx_context::sender(ctx)
        };
        let game_admin = GameAdmin{
            id:object::new(ctx),
            game_id,
            monsters:0,
        };
        transfer::freeze_object(game_info,sender);
        transfer::transfer(game_admin,sender);
    };

    // function để create các vật phẩm, nhân vật trong game.
    fun create_hero(game: &GameInfo, name:String,sword:Sword,armor:Armor,coin:coin::Coin<SUI>,ctx: &mut TxContext):Hero {
         assert!(coin::value(&coin) > 10 , ENotEnough);
         transfer::public_transfer(coin,game.admin);
         Hero{
            id:object::new(ctx),
            name,
            hp:100,
            experience:0,
            sword:option::some(sword),
            armor:option::some(armor),
            game_id:object::id(game).
         }

    }
    fun create_sword(game: &GameInfo,coin:coin::Coin<SUI>,ctx: &mut TxContext):Sword {
        let amount = coin::value(&coin);
        assert!(coin::value(&coin) > 0 , ENotEnough);
        transfer::public_transfer(coin,game.admin);
        Sword{
            id:object::new(ctx);
            attack: amount *3 ,
            strenght: amount *2,
            game_id:object::id(game)
        }
    }
    fun create_armor(game:&GameInfo,coin:coin::Coin<SUI>,ctx: &mut TxContext):Armor {
        let amount = coin::value(&coin);
        assert!(coin::value(&coin) > 5 , ENotEnough);
        transfer::public_transfer(coin,game.admin);
        Armor{
            id:object::new(ctx),
            defense:amount*2 ,
            game_id:object::id(game)
        }
    }

    // function để create quái vật, chiến đấu với hero, chỉ admin mới có quyền sử dụng function này
    // Gợi ý: khởi tạo thêm 1 object admin.
    fun create_monter(admin: &GameAdmin,game: &GameInfo,hp:u64,strenght:u64,player:address){
        admin.monsters = admin.monsters +1;
        let monter = Monter{
           id:object::new(ctx);
           hp: u64,
           strenght: u64,
           game_id:object::id(game)
        }
        transfer::public_transfer(monter,player)

    }

    // func để tăng điểm kinh nghiệm cho hero sau khi giết được quái vật
    fun level_up_hero(hero:&mut Hero,experience:u64) {
        hero.experience = hero.experience + experience;
    }
    fun level_up_sword(sword:&mut Sword, attack: u64, strenght: u64,) {
          sword.attack + attack;
          sword.strenght +strenght;
    }
    fun level_up_armor(armor:&mut Armor,defense:u64) {
        armor.defense + defense;
    }

    public fun get_hero_hp(hero:&Hero):u64{
        if(hero.hp ==0){
            return 0
        };
        let sword_strenght = if(option::is_some(&hero.sword)){
            sword_strenght(option::borrow(&hero.sword))
        }else{
            0
        };
        (hero.experience + hero.hp) + sword_strenght
    }
    public fun sword_strenght(sword:&Sword):u64{
        sword.strenght + sword. attack
    }
    // Tấn công, hoàn thiện function để hero và monter đánh nhau
    // gợi ý: kiểm tra số điểm hp và strength của hero và monter, lấy hp trừ đi số sức mạnh mỗi lần tấn công. HP của ai về 0 trước người đó thua
    public entry fun attack_monter(game:&GameInfo,hero:&mut Hero,monter:&Monter,ctx: &mut TxContext) {
        let Monter{id:monter_id,hp:monter_hp,game_id:_} = monter;
        let hero_hp = get_hero_hp(hero);
        While(monter_hp > hero_hp){
            monter_hp = monter_hp - hero_hp;
            assert!(hero_hp >= monter_hp,MonterWin);
            hero_hp = hero_hp - monter_hp;
        };
        hero.hp = hero_hp;
        hero.experience = hero.experience + 10;
        if(option::is_some(&hero.sword)){
            level_up_sword(option::borrow_mut(&mut hero.sword),2,4)
        }
      object::delete(monter_id)
    }

}
