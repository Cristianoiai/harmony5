import { Chat, Contact } from "@whiskeysockets/baileys";
import Baileys from "../../models/Baileys";
import { isArray } from "lodash";

interface Request {
  whatsappId: number;
  contacts?: Contact[];
  chats?: Chat[];
}

const createOrUpdateBaileysService = async ({
  whatsappId,
  contacts,
  chats
}: Request): Promise<Baileys> => {
  // Log para depuração dos parâmetros recebidos
  console.log("Parâmetros recebidos:", { whatsappId, contacts, chats });

  // Validação de `whatsappId`
  if (!whatsappId) {
    throw new Error("whatsappId é obrigatório e deve ser um número.");
  }

  // Busca registro existente com o `whatsappId`
  const baileysExists = await Baileys.findOne({
    where: { whatsappId }
  });

  if (baileysExists) {
    // Recupera e converte os dados existentes, se houver
    let getChats: Chat[] = baileysExists.chats
      ? JSON.parse(baileysExists.chats)
      : [];
    let getContacts: Contact[] = baileysExists.contacts
      ? JSON.parse(baileysExists.contacts)
      : [];

    // Validação e atualização de `chats`
    if (chats && Array.isArray(chats)) {
      getChats = Array.from(new Set(getChats.concat(chats))).sort();
    }

    // Validação e atualização de `contacts`
    if (contacts && Array.isArray(contacts)) {
      getContacts = Array.from(new Set(getContacts.concat(contacts))).sort();
    }

    // Atualização do registro existente
    const newBaileys = await baileysExists.update({
      chats: JSON.stringify(getChats),
      contacts: JSON.stringify(getContacts)
    });

    return newBaileys;
  }

  // Criação de um novo registro caso não exista
  const baileys = await Baileys.create({
    whatsappId,
    contacts: JSON.stringify(Array.isArray(contacts) ? contacts : []),
    chats: JSON.stringify(Array.isArray(chats) ? chats : [])
  });

  return baileys;
};

export default createOrUpdateBaileysService;

