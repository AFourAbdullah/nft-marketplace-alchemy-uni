//require('dotenv').config();
const key = process.env.REACT_APP_PINATA_KEY;
const secret = process.env.REACT_APP_PINATA_SECRET;
// const JWT = `Bearer ${process.env.REACT_APP_PINATA_JWT}`;
const JWT = `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiI2ZTM4N2IxOC0yMzc3LTRkYjQtYTdiMS03ZGFhYzBjNmViYTIiLCJlbWFpbCI6ImFiZHVsbGFoYXplZXM0QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImlkIjoiRlJBMSIsImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxfSx7ImlkIjoiTllDMSIsImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxfV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiI4OWJjZWZmMTQ3ZjJjNzVhYjA0YiIsInNjb3BlZEtleVNlY3JldCI6ImM2YzFlYTA1Y2Y3ZjJlNzQ2OTdjYzJmZjY1NzRkZDNjOWRmZmM4NWM5NzcxYmQzZGE0NzQ2YzAxNjc2NGNlNzIiLCJpYXQiOjE2OTMwNDYwMjN9.nzU3K8UafYcS9begIVeMWKQ3vTLJGRW8AJt31FelFdU`;

const axios = require("axios");
const FormData = require("form-data");

export const uploadJSONToIPFS = async (JSONBody) => {
  const url = `https://api.pinata.cloud/pinning/pinJSONToIPFS`;
  //making axios POST request to Pinata ⬇️
  return axios
    .post(url, JSONBody, {
      headers: {
        pinata_api_key: key,
        pinata_secret_api_key: secret,
      },
    })
    .then(function (response) {
      return {
        success: true,
        pinataURL:
          "https://gateway.pinata.cloud/ipfs/" + response.data.IpfsHash,
      };
    })
    .catch(function (error) {
      console.log(error);
      return {
        success: false,
        message: error.message,
      };
    });
};
export const uploadMetadata = async ({ name, description, price, image }) => {
  try {
    const data = JSON.stringify({
      pinataContent: {
        name: name, // Use the 'name' provided
        description: description,
        price: price,
        file: `ipfs://${image}`, // Use the 'imageUri' directly
      },
      pinataMetadata: {
        name: name, // Use the 'name' provided
      },
    });

    const res = await fetch("https://api.pinata.cloud/pinning/pinJSONToIPFS", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: JWT,
      },
      body: data,
    });
    const resData = await res.json();
    console.log("Metadata uploaded, CID:", resData.IpfsHash);

    return resData.IpfsHash;
  } catch (error) {
    console.log(error);
  }
};
export const uploadFileToIPFS = async (file) => {
  const formData = new FormData();

  formData.append("file", file);

  const metadata = JSON.stringify({
    name: "nft",
  });
  formData.append("pinataMetadata", metadata);

  const options = JSON.stringify({
    cidVersion: 0,
  });
  formData.append("pinataOptions", options);

  try {
    const res = await axios.post(
      "https://api.pinata.cloud/pinning/pinFileToIPFS",
      formData,
      {
        maxBodyLength: "Infinity",
        headers: {
          "Content-Type": `multipart/form-data; boundary=${formData._boundary}`,
          Authorization: JWT,
        },
      }
    );
    console.log("pin res issss", res.data);
    return res;
  } catch (error) {
    console.log(error);
  }
};
